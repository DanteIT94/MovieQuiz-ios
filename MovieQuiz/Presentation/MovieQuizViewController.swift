import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private var correctAnswers:Int = 0
    
    @IBOutlet private var imageLabel: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10 //общее колличество вопросов квиза
    private var questionFactory: QuestionFactoryProtocol? //"Фабрика вопросов" к которой наш контроллер будет обращаться за вопросами.
    //Для использования "Фабрики" - применяем "Композицию". Так мы сами создали экземпляр фабрики, который будем использовать.
    private var currentQuestion: QuizQuestion? //Текущий вопрос, который видит пользователь
    
    //private lazy var currentQuestion = questions[currentQuestionIndex]

    override func viewDidLoad() {
        super.viewDidLoad()
        imageLabel.layer.cornerRadius = 20
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        yesButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        yesButton.addTarget(self, action: #selector(yesButtonPressed), for: .touchDown)
        yesButton.addTarget(self, action: #selector(yesButtonReleased), for: [.touchUpInside, .touchUpOutside])
        noButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        noButton.addTarget(self, action: #selector(noButtonPressed), for: .touchDown)
        noButton.addTarget(self, action: #selector(noButtonReleased), for: [.touchUpInside, .touchUpOutside])
    }
    //Mark: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in //Если в замыканиях есть self, нужно использовать weak self. "Ослабленный" self является опционалом.
            self?.show(quiz: viewModel)
        }
        //Это тот же код что в viewDidLoad, но мы поменяли конструкцию с if-let на guard-let.
        //Конструкция guard-let вынуждает выходить из функции, если условие на выполнено. Поэтому мы использовали if-let. Если вопрос пришел бы как nil, работа метода "didRecieve..." не имела бы смысла.
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        //        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController( title: result.title,
                                       message: result.text,
                                       preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default, handler: { [weak self] _ in
            guard let self = self else {return}
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            //Если мы пишем замыкания внутри класса, то, чтобы обратиться к полям и функциям этого класса из замыкания, Swift требует написать self (показываем, что это не общие параметры замыкания, а именно поля и функции класса)
            self.questionFactory?.requestNextQuestion()
        })
        alert.addAction(action)
        self.present(alert,animated: true, completion: nil)
    }
    
    private func show(quiz step: QuizStepViewModel){
        counterLabel.text = step.questionNumber
        imageLabel.image = step.image
        textLabel.text = step.question
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageLabel.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageLabel.layer.borderWidth = 8 // толщина рамки
        imageLabel.layer.borderColor = isCorrect ? UIColor.YPGreen?.cgColor : UIColor.YPRed?.cgColor
        imageLabel.layer.cornerRadius = 20 // радиус скругления углов рамки
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, Вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
//            let text = "Ваш результат: \(correctAnswers) из 10"
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен",
                                                 text: text,
                                                 buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
        imageLabel.layer.borderWidth = 0
    }
    
    @objc private func yesButtonPressed() {
        UIView.animate(withDuration: 0.1, animations: {
            self.yesButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        yesButton.isEnabled = false
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
        guard let self = self else {return}
        self.yesButton.isEnabled = true
        }
    }
    
    @objc private func noButtonPressed() {
        UIView.animate(withDuration: 0.1, animations: {
            self.noButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        noButton.isEnabled = false
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
        guard let self = self else {return}
        self.noButton.isEnabled = true
        }
    }
    
    @objc private func yesButtonReleased() {
        UIView.animate(withDuration: 0.1, animations: {
            self.yesButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }
    
    @objc private func noButtonReleased() {
        UIView.animate(withDuration: 0.1, animations: {
            self.noButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }
}



/*
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
