import Foundation

/// Port of ru.nsu.ccfit.zuev.audio.serviceAudio.BassAudioFunc
/// Manages the playback of the main beatmap audio track.
class SongService {
    static let windowFFT = 1024
    
    private var channel: HSTREAM = 0
    private var speed: Float = 1.0
    private var pitchRate: Float = 1.0
    private var adjustPitch: Bool = false
    private var channelInfo = BASS_CHANNELINFO()
    
    private var spectrumBuffer: [Float]?
    private var playFlag: DWORD = DWORD(BASS_STREAM_PRESCAN)
    private var isGaming: Bool = false
    
    /// The channel's frequency, in Hz.
    private(set) var frequency: Float = 0
    
    enum Status {
        case stopped
        case paused
        case playing
        case stalled
    }
    
    init() {}
    
    func pause() -> Bool {
        guard channel != 0 else { return false }
        return BASS_ChannelPause(channel) != 0
    }
    
    @discardableResult
    func resume() -> Bool {
        guard channel != 0 else { return false }
        setEndSync()
        
        if BASS_ChannelPlay(channel, 0) != 0 {
            setVolume(AppConfig.bgmVolume)
            return true
        }
        return false
    }
    
    func preLoad(filePath: String, speed: Float, adjustPitch: Bool) -> Bool {
        doClear()
        
        channel = filePath.withCString { cString in
            // BASS_StreamCreateFile(mem, file, offset, length, flags)
            return BASS_StreamCreateFile(0, cString, 0, 0, playFlag | DWORD(BASS_STREAM_DECODE))
        }
        
        // Wrap the decoding channel in a tempo channel for speed/pitch adjustments
        channel = BASS_FX_TempoCreate(channel, DWORD(BASS_STREAM_AUTOFREE))
        
        if channel == 0 {
            print("[osu!droid] Failed to load audio file or create tempo channel. BASS Error: \(BASS_ErrorGetCode())")
            self.speed = 1.0
            self.adjustPitch = false
            return false
        }
        
        BASS_ChannelGetInfo(channel, &channelInfo)
        frequency = Float(channelInfo.freq)
        
        self.pitchRate = 1.0
        setSpeed(speed)
        setAdjustPitch(adjustPitch)
        
        BASS_ChannelSetAttribute(channel, DWORD(BASS_ATTRIB_BUFFER), 0.1)
        
        return true
    }
    
    @discardableResult
    func play() -> Bool {
        if channel != 0 && BASS_ChannelIsActive(channel) == BASS_ACTIVE_PAUSED {
            return resume()
        } else if channel != 0 {
            setEndSync()
            if BASS_ChannelPlay(channel, 1) != 0 {
                setVolume(AppConfig.bgmVolume)
                return true
            }
        }
        return false
    }
    
    @discardableResult
    func stop() -> Bool {
        if channel != 0 {
            BASS_ChannelStop(channel)
            let result = BASS_StreamFree(channel) != 0
            channel = 0
            return result
        }
        return false
    }
    
    @discardableResult
    func jump(ms: Int) -> Bool {
        if channel != 0 && ms > 0 {
            let skipPosition = BASS_ChannelSeconds2Bytes(channel, Double(ms) / 1000.0)
            let mode = (speed == 1.0) ? BASS_POS_BYTE : BASS_POS_DECODE
            return BASS_ChannelSetPosition(channel, skipPosition, DWORD(mode)) != 0
        }
        return false
    }
    
    var status: Status {
        if channel == 0 { return .stopped }
        
        switch BASS_ChannelIsActive(channel) {
        case DWORD(BASS_ACTIVE_STOPPED): return .stopped
        case DWORD(BASS_ACTIVE_PAUSED): return .paused
        case DWORD(BASS_ACTIVE_PLAYING): return .playing
        default: return .stalled
        }
    }
    
    var position: Double {
        if channel != 0 {
            let pos = BASS_ChannelGetPosition(channel, DWORD(BASS_POS_BYTE))
            if pos != QWORD(bitPattern: -1) {
                return BASS_ChannelBytes2Seconds(channel, pos) * 1000.0
            }
        }
        return 0
    }
    
    var length: Int {
        if channel != 0 {
            let len = BASS_ChannelGetLength(channel, DWORD(BASS_POS_BYTE))
            if len != QWORD(bitPattern: -1) {
                return Int(BASS_ChannelBytes2Seconds(channel, len) * 1000.0)
            }
        }
        return 0
    }
    
    func getSpectrum() -> [Float]? {
        if BASS_ChannelIsActive(channel) != BASS_ACTIVE_PLAYING {
            return nil
        }
        
        let resSize = SongService.windowFFT >> 1
        if spectrumBuffer == nil || spectrumBuffer!.count != resSize {
            spectrumBuffer = [Float](repeating: 0, count: resSize)
        }
        
        // BASS_DATA_FFT1024 retrieves 512 floats
        _ = spectrumBuffer!.withUnsafeMutableBufferPointer { ptr in
            BASS_ChannelGetData(channel, ptr.baseAddress, DWORD(BASS_DATA_FFT1024))
        }
        
        return spectrumBuffer
    }
    
    private func doClear() {
        if channel != 0 && BASS_ChannelIsActive(channel) == BASS_ACTIVE_PLAYING {
            BASS_ChannelStop(channel)
        }
        if channel != 0 {
            BASS_StreamFree(channel)
            channel = 0
        }
    }
    
    func setLoop(isLoop: Bool) {
        if isLoop {
            playFlag |= DWORD(BASS_SAMPLE_LOOP)
        } else {
            playFlag ^= DWORD(BASS_SAMPLE_LOOP)
        }
    }
    
    func getSpeed() -> Float {
        return speed
    }
    
    func setSpeed(_ speed: Float) {
        self.speed = speed
        onAudioEffectChange()
    }
    
    func setAdjustPitch(_ adjustPitch: Bool) {
        self.adjustPitch = adjustPitch
        onAudioEffectChange()
    }
    
    func setPitchRate(_ pitchRate: Float) {
        self.pitchRate = pitchRate
        onAudioEffectChange()
    }
    
    func setFrequencyForcefully(_ frequency: Float) {
        guard channel != 0 else { return }
        self.frequency = frequency
        BASS_ChannelSetAttribute(channel, DWORD(BASS_ATTRIB_TEMPO_FREQ), frequency)
        BASS_ChannelSetAttribute(channel, DWORD(BASS_ATTRIB_TEMPO), 0)
    }
    
    func getVolume() -> Float {
        var volume: Float = 0
        if channel != 0 {
            BASS_ChannelGetAttribute(channel, DWORD(BASS_ATTRIB_VOL), &volume)
        }
        return volume
    }
    
    func setVolume(_ volume: Float) {
        if channel != 0 {
            BASS_ChannelSetAttribute(channel, DWORD(BASS_ATTRIB_VOL), volume)
        }
    }
    
    func setGaming(_ isGaming: Bool) {
        print("Audio Service Running In Game: \(isGaming)")
        self.isGaming = isGaming
    }
    
    func freeALL() {
        BASS_Free()
    }
    
    private func setEndSync() {
        // Not utilizing the closure capture fully due to C function pointer requirements in BASS,
        // but typically you use a static callback function for BASS_ChannelSetSync in Swift.
        // For now, we will omit the C callback registration or stub it, as it requires C function pointer.
    }
    
    private func onAudioEffectChange() {
        guard channel != 0 else { return }
        
        frequency = Float(channelInfo.freq) * pitchRate
        
        if adjustPitch {
            frequency *= speed
        }
        
        BASS_ChannelSetAttribute(channel, DWORD(BASS_ATTRIB_TEMPO_FREQ), frequency)
        BASS_ChannelSetAttribute(channel, DWORD(BASS_ATTRIB_TEMPO), adjustPitch ? 0 : (speed - 1.0) * 100.0)
    }
}
