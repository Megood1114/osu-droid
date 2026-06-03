import Foundation

/// Port of ru.nsu.ccfit.zuev.audio.BassSoundProvider
/// Manages loading and playback of individual sound effects using BASS.
class BassSoundProvider {
    
    static let empty = BassSoundProvider()
    
    private var sample: HSAMPLE = 0
    private var channel: HCHANNEL = 0
    private var volume: Float = 1.0
    private var looping: Bool = false
    
    /// The rate at which the sound is played back (affects pitch). 1 is 100% playback speed.
    private var frequency: Float = 1.0
    
    private var sampleInfo = BASS_SAMPLE()
    
    /// Loads a sound sample from a file path.
    func prepare(fileName: String?) -> Bool {
        free()
        
        guard let fileName = fileName, !fileName.isEmpty else {
            sample = 0
            return false
        }
        
        // BASS_SampleLoad(BOOL mem, const void *file, QWORD offset, DWORD length, DWORD max, DWORD flags)
        // mem = false (loading from file path)
        sample = fileName.withCString { cString in
            // UnsafeRawPointer(cString)
            return BASS_SampleLoad(0, cString, 0, 0, 1, DWORD(BASS_SAMPLE_OVER_POS))
        }
        
        if sample != 0 {
            BASS_SampleGetInfo(sample, &sampleInfo)
            applyAudioEffectsToSample()
        }
        
        return sample != 0
    }
    
    /// Play the sound at full volume.
    func play() {
        play(volume: 1.0)
    }
    
    /// Play the sound at a specific volume multiplier.
    func play(volume: Float) {
        guard sample != 0 else { return }
        
        self.volume = volume
        let finalVolume = volume * AppConfig.soundVolume // Uses global config
        
        if finalVolume == 0 {
            stop()
            return
        }
        
        if channel == 0 {
            channel = BASS_SampleGetChannel(sample, DWORD(BASS_SAMCHAN_STREAM))
            
            if channel == 0 {
                return
            }
            
            applyAudioEffectsToChannel()
            // BASS_ChannelSetAttribute(handle, attrib, value)
            BASS_ChannelSetAttribute(channel, DWORD(BASS_ATTRIB_NOBUFFER), 1.0)
        }
        
        guard channel != 0 else { return }
        
        // Ensure the current playback is stopped first
        stop()
        
        // Play the channel (restart = true)
        BASS_ChannelPlay(channel, 1)
        BASS_ChannelSetAttribute(channel, DWORD(BASS_ATTRIB_VOL), finalVolume)
    }
    
    /// Stop playback.
    func stop() {
        guard channel != 0 else { return }
        
        if BASS_ChannelIsActive(channel) == BASS_ACTIVE_PLAYING {
            BASS_ChannelStop(channel)
        }
    }
    
    /// Free the loaded sample and its channel.
    func free() {
        guard sample != 0 else { return }
        
        BASS_SampleFree(sample)
        sample = 0
        channel = 0
    }
    
    /// Set looping mode.
    func setLooping(_ looping: Bool) {
        guard self.looping != looping else { return }
        
        self.looping = looping
        applyAudioEffectsToSample()
        applyAudioEffectsToChannel()
    }
    
    /// Set playback frequency/pitch modifier.
    func setFrequency(_ frequency: Float) {
        guard self.frequency != frequency else { return }
        
        self.frequency = frequency
        applyAudioEffectsToChannel()
    }
    
    /// Set the volume modifier.
    func setVolume(_ volume: Float) {
        guard self.volume != volume else { return }
        
        self.volume = volume
        applyAudioEffectsToChannel()
    }
    
    // MARK: - Private Effects Application
    
    private func applyAudioEffectsToSample() {
        guard sample != 0 else { return }
        
        if looping {
            sampleInfo.flags |= DWORD(BASS_SAMPLE_LOOP)
        } else {
            sampleInfo.flags ^= DWORD(BASS_SAMPLE_LOOP)
        }
        
        BASS_SampleSetInfo(sample, &sampleInfo)
    }
    
    private func applyAudioEffectsToChannel() {
        guard channel != 0 else { return }
        
        if looping {
            BASS_ChannelFlags(channel, DWORD(BASS_SAMPLE_LOOP), DWORD(BASS_SAMPLE_LOOP))
        } else {
            BASS_ChannelFlags(channel, 0, DWORD(BASS_SAMPLE_LOOP))
        }
        
        BASS_ChannelSetAttribute(channel, DWORD(BASS_ATTRIB_VOL), volume * AppConfig.soundVolume)
        BASS_ChannelSetAttribute(channel, DWORD(BASS_ATTRIB_FREQ), Float(sampleInfo.freq) * frequency)
    }
}
