import Foundation

public enum Key: Equatable {
    case char(Character)
    case ctrl(Character)
    case arrow(ArrowDirection)
    case enter
    case backspace
}

public enum ArrowDirection {
    case up
    case down
    case left
    case right
}
