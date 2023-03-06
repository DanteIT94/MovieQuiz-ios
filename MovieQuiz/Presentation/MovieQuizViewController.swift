import UIKit


protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func wrongAnswer()
    func updateButtonTitle(withTime time: Int)
}

final class MovieQuizViewController: UIViewController {
    
    //MARK: Private Properties
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet  private var imageLabel: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    private var presenter: MovieQuizPresenter!
    private var  alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServices?
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageLabel.layer.cornerRadius = 20
        presenter = MovieQuizPresenter(viewController: self)
        presenter?.startTimer()
        ///Мы вынесли Alert в отдельный модуль
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
        
        ///Отработка нажатий по кнопка
        yesButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        yesButton.addTarget(self, action: #selector(yesButtonPressed), for: .touchDown)
        yesButton.addTarget(self, action: #selector(yesButtonReleased), for: [.touchUpInside, .touchUpOutside])
        noButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        noButton.addTarget(self, action: #selector(noButtonPressed), for: .touchDown)
        noButton.addTarget(self, action: #selector(noButtonReleased), for: [.touchUpInside, .touchUpOutside])
    }
    
    //MARK: Private Methods for buttons
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    //MARK: Обработка нажатия + запрет на повторное нажатие игроком
    @objc private func yesButtonPressed() {
        UIView.animate(withDuration: 0.1, animations: {
            self.yesButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        yesButton.isEnabled = false
        noButton.isEnabled = false
        presenter?.stopTimer()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            guard let self = self else {return}
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    @objc private func noButtonPressed() {
        UIView.animate(withDuration: 0.1, animations: {
            self.noButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        noButton.isEnabled = false
        yesButton.isEnabled = false
        presenter?.stopTimer()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            guard let self = self else {return}
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
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

extension MovieQuizViewController: MovieQuizViewControllerProtocol {
    
    func showLoadingIndicator() {
        ///Индикатор загрузки не скрыт
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        let alert = AlertModel(title: "Ошибка", message: message, buttonText: "Попробуйте ещё раз") {[weak self] in
            guard let self = self else {return}
            self.presenter.restartGame()
        }
        alertPresenter?.show(result: alert)
    }
    
    func show(quiz step: QuizStepViewModel){
        imageLabel.layer.borderColor = UIColor.clear.cgColor
        counterLabel.text = step.questionNumber
        imageLabel.image = step.image
        textLabel.text = step.question
        self.hideLoadingIndicator()
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let text = presenter.resultMessage
        let alert = AlertModel(title: "Этот раунд окончен!",
                               message: text,
                               buttonText: "Сыграть еще раз") { [weak self]  in
            guard let self = self else {return}
            self.presenter.restartGame()
        }
        alertPresenter?.show(result: alert)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageLabel.layer.masksToBounds = true
        /// толщина рамки
        imageLabel.layer.borderWidth = 8
        imageLabel.layer.borderColor = isCorrectAnswer ? UIColor.YPGreen?.cgColor : UIColor.YPRed?.cgColor
        /// радиус скругления углов рамки
        imageLabel.layer.cornerRadius = 20
    }
    func wrongAnswer() {
        feedbackGenerator.notificationOccurred(.error)
    }
    
    func updateButtonTitle(withTime time: Int) {
        let yesButtonTitle = "Да (\(time))"
        let noButtonTitle = "Нет (\(time))"
        yesButton.setTitle(yesButtonTitle, for: .normal)
        noButton.setTitle(noButtonTitle, for: .normal)
    }
}
