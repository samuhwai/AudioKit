//
//  AKCallbackInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// MIDI Instrument that triggers functions on MIDI note on/off commands
open class AKCallbackInstrument: AKMIDIInstrument {

    // MARK: Properties

    /// All callbacks that will get triggered by MIDI events
    open var callback: AKMIDICallback?

    /// Initialize the callback instrument
    ///
    /// - parameter midiInputName: Name of the instrument's MIDI input
    /// - parameter callback: Initial callback
    ///
    public init(midiInputName: String = "AudioKit Callback Instrument", callback: AKMIDICallback? = nil) {
        super.init(midiInputName: midiInputName)
        self.name = midiInputName
        self.callback = callback
        avAudioNode = AVAudioMixerNode()
        AudioKit.engine.attach(self.avAudioNode)
    }

    fileprivate func triggerCallbacks(_ status: AKMIDIStatus,
                                      data1: MIDIByte,
                                      data2: MIDIByte) {
        _ = callback.map { $0(status.byte, data1, data2) }
    }

    /// Will trigger in response to any noteOn Message
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number being started
    ///   - velocity:   MIDI Velocity (0-127)
    ///   - channel:    MIDI Channel
    ///
    override open func start(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel) {
        triggerCallbacks(AKMIDIStatus(statusType: .noteOn, channel: channel), data1: noteNumber, data2: velocity)
    }

    /// Will trigger in response to any noteOff Message
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number being stopped
    ///   - channel:    MIDI Channel
    ///
    override open func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel) {
        triggerCallbacks(AKMIDIStatus(statusType: .noteOn, channel: channel), data1: noteNumber, data2: 0)
    }
}
