public enum MyChatMessageType: Int, Sendable {
    /// Сообщение клиента, бота или оператора
    case visitorMessage = 1

    /// Отправка подтверждения
    case sentConfirmation = 2

    /// Подтверждение прочтения сообщения клиентом
    case readingConfirmation = 4

    /// Подтверждение прочтения сообщения клиента чатботом
    case receivedByMediator = 11

    /// Подтверждение прочтения сообщения клиента оператором
    case receivedByOperator = 12

    /// Оператор набирает сообщение
    case operatorIsTyping = 13

    /// Оператор закончил набирать сообщение
    case operatorStoppedTyping = 14

    /// Обновление оценки оператора в диалоге
    case updateDialogScore = 15

    /// Завершение диалога
    case finishDialog = 16

    /// Уведомление о намерении клиента завершить диалог
    case closeDialogIntention = 17

    /// Уведомление о переключении на оператора
    case connectedOperator = 18

    /// Обновление негативной причины завершения диалога
    case updateNegativeReason = 21

    /// Оператор отправил сообщение удержания (hold)
    case clientHold = 23

    case unknown
}
