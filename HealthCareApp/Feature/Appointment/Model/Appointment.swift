//
//  Appointment.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 03/07/25.
//

import Foundation
import Combine


// MARK: - Appointment Model
final class Appointment: Identifiable, ObservableObject {
    let id: UUID
    @Published var title: String
    @Published var doctor: String
    @Published var date: Date
    @Published var location: String
    @Published var notes: String?
    @Published var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String,
        doctor: String,
        date: Date,
        location: String,
        notes: String? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.doctor = doctor
        self.date = date
        self.location = location
        self.notes = notes
        self.isCompleted = isCompleted
    }
}
