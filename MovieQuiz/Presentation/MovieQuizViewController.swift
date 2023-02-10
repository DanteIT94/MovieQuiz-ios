import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    //MARK: Private Properties
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private var correctAnswers:Int = 0
    
    @IBOutlet private var imageLabel: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10 //общее колличество вопросов квиза
    private var questionFactory: QuestionFactoryProtocol? //"Фабрика вопросов" к которой наш контроллер будет обращаться за вопросами.
    //Для использования "Фабрики" - применяем "Композицию".
    private var currentQuestion: QuizQuestion? //Текущий вопрос, который видит пользователь
    private var  alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServices?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSHomeDirectory())
        questionFactory = QuestionFactory(delegate: self)
        statisticService = StatisticServicesImplementation()
        questionFactory?.requestNextQuestion()
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
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
    
    //Mark: Private Methods
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
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
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
            self.imageLabel.layer.borderWidth = 0
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            guard let statisticService  = statisticService else {return}
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let accurancyInPersent = String(format: "%.2f", (statisticService.totalAccurancy * 100)) + "%"
            let localilizedTime = statisticService.bestGame.date.dateTimeString
            let bestGameStatistic = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"
            
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n Колличество сыгранных квизов: \(statisticService.gamesCount)\n Рекорд: \(bestGameStatistic) (\(localilizedTime))\n Средняя точность: \(accurancyInPersent)"
            
            let alert = AlertModel(title: "Этот раунд окончен!",
                                        message: text,
                                        buttonText: "Сыграть еще раз") { [weak self]  in
                guard let self = self else {return}
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
            alertPresenter?.show(result: alert)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
//Mark: Обработка нажатия + запрет на повторное нажатие игроком
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

