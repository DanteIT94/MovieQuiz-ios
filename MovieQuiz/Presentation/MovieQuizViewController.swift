import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private var imageLabel: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    private var currentQuestionIndex: Int = 0
    private lazy var currentQuestion = questions[currentQuestionIndex]
    private var correctAnswers:Int = 0
    
    struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageLabel.layer.cornerRadius = 20
        let viewModel = convert(model: currentQuestion)
        show(quiz: viewModel)
        yesButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        yesButton.addTarget(self, action: #selector(yesButtonPressed), for: .touchDown)
        yesButton.addTarget(self, action: #selector(yesButtonReleased), for: [.touchUpInside, .touchUpOutside])
        noButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        noButton.addTarget(self, action: #selector(noButtonPressed), for: .touchDown)
        noButton.addTarget(self, action: #selector(noButtonReleased), for: [.touchUpInside, .touchUpOutside])
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController( title: result.title,
                                       message: result.text,
                                       preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default, handler: { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            let firstQuestionsAgain = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestionsAgain)
            self.show(quiz: viewModel)
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
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageLabel.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageLabel.layer.borderWidth = 8 // толщина рамки
        imageLabel.layer.borderColor = isCorrect ? UIColor.YPGreen?.cgColor : UIColor.YPRed?.cgColor
        imageLabel.layer.cornerRadius = 20 // радиус скругления углов рамки
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers) из 10"
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен",
                                                 text: text,
                                                 buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            let nextQuestions = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestions)
            show(quiz: viewModel)
        }
        imageLabel.layer.borderWidth = 0
    }
    
    @objc private func yesButtonPressed() {
        UIView.animate(withDuration: 0.1, animations: {
            self.yesButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        yesButton.isEnabled = false
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
        self.yesButton.isEnabled = true
        }
    }
    
    @objc private func noButtonPressed() {
        UIView.animate(withDuration: 0.1, animations: {
            self.noButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        noButton.isEnabled = false
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
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
