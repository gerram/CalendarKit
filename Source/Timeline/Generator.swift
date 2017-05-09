import Foundation

struct Generator {
  static func timeStrings24H() -> [String] {
    var numbers = [String]()
    numbers.append("00:00")

    for i in 1...24 {
      let i = i % 24
      var string = i < 10 ? "0" + String(i) : String(i)
      string.append(":00")
      numbers.append(string)
    }

    return numbers
  }

  static func timeStrings12H() -> [String] {
    var numbers = [String]()
    numbers.append("12")

    for i in 1...11 {
      let string = String(i)
      numbers.append(string)
    }

    var am = numbers.map { $0 + " AM" }
    var pm = numbers.map { $0 + " PM" }
    am.append("Noon")
    pm.removeFirst()
    pm.append(am.first!)
    return am + pm
  }
    
    static func timeString24H_MIN(by interval: TimeLineInterval = TimeLineInterval.TimeLineInterval1Hour) -> [String] {
        
        var numbers = [String]()
        numbers.append("00:00")
        
        switch interval {
        case TimeLineInterval.TimeLineInterval1Hour:
            return Generator.timeStrings24H()
            break
            
        case TimeLineInterval.TimeLineInterval30Minutes:
            numbers.append("00:30")
            
            for i in 1...24 {
                let i = i % 24
                let string = i < 10 ? "0" + String(i) : String(i)
                
                var stringH = string
                stringH.append(":00")
                numbers.append(stringH)
                
                if i > 0 {
                    var stringM = string
                    stringM.append(":30")
                    numbers.append(stringM)
                }
            }
            break
            
        case TimeLineInterval.TimeLineInterval15Minutes:
            var minutesCollection = [String]()
            for i in sequence(first: 15, next: {$0 + 15 < 60 ? $0 + 15 : nil}) {
                minutesCollection.append(String(i))
            }
            _ = minutesCollection.map({ numbers.append("00:"+$0) })
            
            for i in 1...24 {
                let i = i % 24
                let string = i < 10 ? "0" + String(i) : String(i)
                
                var stringH = string
                stringH.append(":00")
                numbers.append(stringH)
                
                if i > 0 {
                    _ = minutesCollection.map({ (item: String) -> String in
                        var stringM = string
                        stringM.append(":" + item)
                        numbers.append(stringM)
                        return stringM
                    })
                }
            }
            break
            
        case TimeLineInterval.TimeLineInterval10Minutes:
            var minutesCollection = [String]()
            for i in sequence(first: 10, next: {$0 + 10 < 60 ? $0 + 10 : nil}) {
                minutesCollection.append(String(i))
            }
            _ = minutesCollection.map({ numbers.append("00:"+$0) })
            
            for i in 1...24 {
                let i = i % 24
                let string = i < 10 ? "0" + String(i) : String(i)
                
                var stringH = string
                stringH.append(":00")
                numbers.append(stringH)
                
                if i > 0 {
                    _ = minutesCollection.map({ (item: String) -> String in
                        var stringM = string
                        stringM.append(":" + item)
                        numbers.append(stringM)
                        return stringM
                    })
                }
            }
            break

        }
        
        return numbers
    }
    

}
