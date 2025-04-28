//
//  ChatMessageBubble.swift
//  
//
//  Created by Илья Малахов on 15.01.2025.
//

import UIKit
import Foundation
import MRDSKit
import SwiftUI

struct ChatMessageBubble: UIViewRepresentable {
    
    @Binding var size: CGSize
    var statusIcon: MRImage?
    let radiusSet: RadiusSet
    let text: String
    let statusSubtitle: String
    let background: IMRColor
    var quote: ChatBubbleQuote? = nil
    let menuActions: [UIAction]
    
    func makeUIView(context: Context) -> BubbleView {
        let view = BubbleView()
        view.setupView(
            backgroundColor: background,
            statusImage: statusIcon,
            radiusSet: radiusSet,
            text: text,
            statusSubtitle: statusSubtitle,
            quote: quote,
            menuActions: menuActions
        )
        
        return view
    }
    
    func updateUIView(_ uiView: BubbleView, context: Context) {
        uiView.set(status: statusIcon)
        DispatchQueue.main.async {
            uiView.layoutIfNeeded()
            size = uiView.sizeThatFits(CGSize(width: 279, height: Double.greatestFiniteMagnitude))
        }
    }
}

// MARK: - BubbleView

class BubbleView: UIView {
    
    // MARK: - UI
    
    private lazy var messageText: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        textView.isSelectable = true
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        textView.isSelectable = true
        textView.delegate = self
        return textView
    }()
    
    private let statusText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusIcon: MRImageView = {
        let image = MRImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    // MARK: - Private properties
    
    private var topLeftRadius: CGFloat = 0
    private var topRightRadius: CGFloat = 0
    private var bottomLeftRadius: CGFloat = 0
    private var bottomRightRadius: CGFloat = 0
    private var textTopConstraint: NSLayoutConstraint?
    
    private var contextActions: [UIAction] = []
    
    // MARK: - Required inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Life Cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCorners()
    }
    
    func setupView(
        backgroundColor: IMRColor,
        statusImage: MRImage?,
        radiusSet: RadiusSet,
        text: String,
        statusSubtitle: String,
        quote: ChatBubbleQuote?,
        menuActions: [UIAction]
    ) {
        // MARK: - setup self
        
        let maxWidth = 279.0
        self.setWidth(to: maxWidth, relation: .lessOrEqual)
        let minWidth = 50.0
        self.setWidth(to: minWidth, relation: .greaterOrEqual)
        self.backgroundColor = backgroundColor.color
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // MARK: - setup radius
        
        topLeftRadius = radiusSet.topLeftRadius
        topRightRadius = radiusSet.topRightRadius
        bottomLeftRadius = radiusSet.bottomLeftRadius
        bottomRightRadius = radiusSet.bottomRightRadius
        
        // MARK: - add interaction menu
        
        contextActions.append(contentsOf: menuActions)
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
        
        // MARK: - setup text view
        
        addSubview(messageText)
        messageText.pinToSuperview(
            edges: [
                .left(.ds12, targetEdge: .left),
                .right(.ds12, targetEdge: .right),
                .bottom(.ds18, targetEdge: .bottom),
            ]
        )
        textTopConstraint = messageText.pinToSuperview(edge: .top(.ds12, targetEdge: .top))
        
        let messageTextConfig = MRTextConfig(
            style: .callout3,
            color: MRTextColor.colorTextPrimary
        )
        
        DispatchQueue.main.async {
            let wrapped = "<span style='white-space: pre-wrap;'>\(text)</span>"
            if let data = wrapped.data(using: .utf8) {
                let attributed = try? NSMutableAttributedString(
                    data: data,
                    options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ],
                    documentAttributes: nil
                )
                let fullRange = NSRange(location: 0, length: attributed?.length ?? 0)
                attributed?.addAttributes(messageTextConfig.textViewAttributes, range: fullRange)
                self.messageText.attributedText = attributed
            }
        }
        
        
        // MARK: - setup status label
        
        addSubview(statusText)
        statusText.pinToSuperview(
            edges: [
                .left(
                    .ds1,
                    targetEdge: .left,
                    relation: .greaterOrEqual
                ),
                .right(
                    statusImage == nil ? .ds12 : .ds32,
                    targetEdge: .right
                ),
                .bottom(.ds6, targetEdge: .bottom)
            ]
        )
        let statusConfig = MRTextConfig(style: .caption2, color: MRTextColor.colorTextCaption)
        statusText.attributedText = statusSubtitle.makeAttributedString(with: statusConfig)
        statusText.sizeToFit()
        
        // MARK: - setup status icon
        
        addSubview(statusIcon)
        statusIcon.pinToSuperview(edges: [
            .right(.ds12, targetEdge: .right),
            .bottom(.ds4, targetEdge: .bottom)
        ])
        statusIcon.setHeight(to: 16.0)
        statusIcon.setWidth(to: 16.0)
        statusIcon.contentMode = .scaleAspectFit
        statusIcon.set(image: statusImage)
        
        // MARK: - add quote if needed
        
        if let quote = quote {
            addQuote(quote: quote)
        }
    }
    
    func addQuote(quote: ChatBubbleQuote) {
        let hosting = UIHostingController(
            rootView: ChatQuoteContent(
                image: quote.image,
                fileImage: quote.fileImage,
                title: quote.title,
                content: quote.content
            )
        )
        guard let quote = hosting.view else { return }
        quote.translatesAutoresizingMaskIntoConstraints = false
        quote.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        quote.backgroundColor = .clear
        
        addSubview(quote)
        quote.pinToSuperview(
            edges: [
                .left(.ds12),
                .top(.ds12),
                .right(.ds12)
            ]
        )
        quote.setHeight(to: 42.0)
        
        textTopConstraint?.isActive = false
        textTopConstraint = messageText.pin(
            edge: .top(.ds8, targetEdge: .bottom),
            to: quote
        )
    }
    
    func set(status icon: MRImage?) {
        statusIcon.set(image: icon)
    }
    
    // MARK: - Helpers
    
    private func updateCorners() {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0, y: topLeftRadius))
        path.addArc(
            withCenter: CGPoint(x: topLeftRadius, y: topLeftRadius),
            radius: topLeftRadius,
            startAngle: .pi,
            endAngle: .pi * 1.5,
            clockwise: true
        )
        
        path.addLine(to: CGPoint(x: bounds.width - topRightRadius, y: 0))
        path.addArc(
            withCenter: CGPoint(x: bounds.width - topRightRadius, y: topRightRadius),
            radius: topRightRadius,
            startAngle: .pi * 1.5,
            endAngle: 0,
            clockwise: true
        )
        
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height - bottomRightRadius))
        path.addArc(
            withCenter: CGPoint(x: bounds.width - bottomRightRadius, y: bounds.height - bottomRightRadius),
            radius: bottomRightRadius,
            startAngle: 0,
            endAngle: .pi * 0.5,
            clockwise: true
        )
        
        path.addLine(to: CGPoint(x: bottomLeftRadius, y: bounds.height))
        path.addArc(
            withCenter: CGPoint(x: bottomLeftRadius, y: bounds.height - bottomLeftRadius),
            radius: bottomLeftRadius,
            startAngle: .pi * 0.5,
            endAngle: .pi,
            clockwise: true
        )
        
        path.close()
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

// MARK: - UIContextMenuInteractionDelegate

extension BubbleView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { [weak self] _ in
                guard let self = self else { return nil }
                return UIMenu(children: self.contextActions)
            }
        )
    }
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionCommitAnimating
    ) {
        animator.preferredCommitStyle = .dismiss
    }
}

// MARK: - UITextViewDelegate

extension BubbleView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        if URL.scheme == "tel" {
            let cleaned = cleanPhoneNumber(URL.absoluteString.removingPercentEncoding ?? "")
            let newUrl: URL? = .init(string: "tel://\(cleaned)")
            if let newUrl = newUrl, UIApplication.shared.canOpenURL(newUrl) {
                UIApplication.shared.open(newUrl)
                return false
            }
        }
        
        return true
    }
    
    private func cleanPhoneNumber(_ number: String) -> String {
        let allowedCharacters = CharacterSet(charactersIn: "+0123456789")
        return number.components(separatedBy: allowedCharacters.inverted).joined()
    }
}
