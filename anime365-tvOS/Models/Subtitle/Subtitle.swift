//
//  Subtitle.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 15.10.2022.
//

import Foundation

enum TypeOfSubtitle {
    case webVTT
}

struct Subtitle {
    
    let type: TypeOfSubtitle
    let text: String
    
    var lines: [SubtitleLine]
    
    mutating func parse() {
        if type == .webVTT {
            parseWebVTT()
        }
    }
    
    private mutating func parseWebVTT() {
        let subLines = text.components(separatedBy: .newlines)
        for line in subLines {
            
            if let range = line.range(of: "[0-9:]+.[0-9]{3} --> [0-9:]+.[0-9]{3}", options: .regularExpression) {
                let partOfTime = line.components(separatedBy: "-->")
                if partOfTime.count != 2 { continue }
                
                guard let fromTime = getSecondFromSubDate(partOfTime[0]) else { continue }
                guard let toTime = getSecondFromSubDate(partOfTime[1]) else { continue }
                
                lines.append(SubtitleLine(
                    from: fromTime,
                    to: toTime,
                    text: ""))
                continue
            }
            
            if lines.count == 0 || line.isEmpty { continue }
            
            let lastIndex = lines.count - 1
            lines[lastIndex].text += line
        }
        print("123")
    }
    
    private func getSecondFromSubDate(_ timeString: String) -> Double? {
        let strForWork = timeString.trimmingCharacters(in: .whitespacesAndNewlines)
        let partOfTime = strForWork.components(separatedBy: ".")
        
        guard var timeInSeconds = Double("0.\(partOfTime[1])") else { return nil }
        
        var partOfLeftTime = partOfTime[0].components(separatedBy: ":")
        var multiplier = 1.0
        
        while partOfLeftTime.count != 0 {
            if let timeInDouble = Double(partOfLeftTime.popLast()!) {
                timeInSeconds += timeInDouble * multiplier
            }
            multiplier *= 60
        }
        
        return Double(round(1000 * timeInSeconds) / 1000)
    }
    
}
