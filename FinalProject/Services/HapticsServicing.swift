//
//  HapticsServicing.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/19/26.
//


import Foundation
import UIKit

protocol HapticsServicing {
    func notifySuccess()
    func notifyWarning()
    func impactRigid()
    func impactSoft()
    func impactLight()
}

struct HapticsService: HapticsServicing {
    func notifySuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    func notifyWarning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    func impactRigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }

    func impactSoft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }

    func impactLight() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}
