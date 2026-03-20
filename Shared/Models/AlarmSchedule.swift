import Foundation

extension Alarm {
    func nextTriggerDate(
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Date {
        if repeatDays.isEmpty {
            return calculateNextTriggerDate(hour: hour, minute: minute, now: now, calendar: calendar)
        }

        return repeatDays
            .map { weekday in
                calculateNextTriggerDate(
                    hour: hour,
                    minute: minute,
                    weekday: weekday,
                    now: now,
                    calendar: calendar
                )
            }
            .min() ?? now
    }
}

func calculateNextTriggerDate(
    hour: Int,
    minute: Int,
    weekday: Weekday? = nil,
    now: Date = Date(),
    calendar: Calendar = .current
) -> Date {
    var components = calendar.dateComponents([.year, .month, .day], from: now)
    components.hour = hour
    components.minute = minute
    components.second = 0

    if let weekday {
        components.weekday = weekday.calendarWeekday
        let candidate = calendar.nextDate(
            after: now.addingTimeInterval(-1),
            matching: components,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .forward
        )
        return candidate ?? now
    }

    guard let todayCandidate = calendar.date(from: components) else {
        return now
    }

    if todayCandidate > now {
        return todayCandidate
    }

    return calendar.date(byAdding: .day, value: 1, to: todayCandidate) ?? todayCandidate
}
