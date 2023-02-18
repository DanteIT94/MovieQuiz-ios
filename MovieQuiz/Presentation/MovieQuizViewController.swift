import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    //MARK: Private Properties
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var imageLabel: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    private var correctAnswers:Int = 0
    private var currentQuestionIndex: Int = 0
    ///общее колличество вопросов квиза
    private let questionsAmount: Int = 10
    ///"Фабрика вопросов" к которой наш контроллер будет обращаться за вопросами.
    private var questionFactory: QuestionFactoryProtocol?//Для использования "Фабрики" - применяем "Композицию".
    ///Текущий вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    private var  alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServices?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageLabel.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServicesImplementation()
        showLoadingIndicator()
        questionFactory?.loadData()
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
        yesButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        yesButton.addTarget(self, action: #selector(yesButtonPressed), for: .touchDown)
        yesButton.addTarget(self, action: #selector(yesButtonReleased), for: [.touchUpInside, .touchUpOutside])
        noButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        noButton.addTarget(self, action: #selector(noButtonPressed), for: .touchDown)
        noButton.addTarget(self, action: #selector(noButtonReleased), for: [.touchUpInside, .touchUpOutside])
    }
    //MARK: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        ///Если в замыканиях есть self, нужно использовать weak self. "Ослабленный" self является опционалом.
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        ///Это тот же код что в viewDidLoad, но мы поменяли конструкцию с if-let на guard-let.Конструкция guard-let вынуждает выходить из функции, если условие на выполнено. Поэтому мы использовали if-let. Если вопрос пришел бы как nil, работа метода "didRecieve..." не имела бы смысла.
    }
    
    //MARK: Private Methods
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
    
    private func showLoadingIndicator() {
        ///Индикатор загрузки не скрыт
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func didLoadDataFromServer() {
        ///Убираем индикатор загрузки
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    private func showNetworkError(message: String) {
        let alert = AlertModel(title: "Ошибка", message: message, buttonText: "Попробуйте ещё раз") {[weak self] in
            guard let self = self else {return}
            self.questionFactory?.loadData()
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
        }
        alertPresenter?.show(result: alert)
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func show(quiz step: QuizStepViewModel){
        counterLabel.text = step.questionNumber
        imageLabel.image = step.image
        textLabel.text = step.question
        self.hideLoadingIndicator()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        /// даём разрешение на рисование рамки
        imageLabel.layer.masksToBounds = true
        /// толщина рамки
        imageLabel.layer.borderWidth = 8
        imageLabel.layer.borderColor = isCorrect ? UIColor.YPGreen?.cgColor : UIColor.YPRed?.cgColor
        /// радиус скругления углов рамки
        imageLabel.layer.cornerRadius = 20
        
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
            showLoadingIndicator()
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
//MARK: Обработка нажатия + запрет на повторное нажатие игроком
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

