//
//  InteractionView.swift
//  
//
//  Created by Илья Малахов on 20.11.2024.
//

import SwiftUI

extension View {
    func contextMenu(actions: [UIAction]) -> some View {
        self.overlay {
            InteractionView(
                parentView: { self },
                menu: UIMenu(title: "", children: actions)
            )
        }
    }
}

private struct InteractionView<Content: View>: UIViewRepresentable {
    @ViewBuilder let parentView: () -> Content
    let menu: UIMenu
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let menuInteraction = UIContextMenuInteraction(delegate: context.coordinator)
        view.addInteraction(menuInteraction)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.parentView = parentView()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            parentView: parentView(),
            menu: menu
        )
    }
    
    class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        var parentView: Content
        let menu: UIMenu
        var view: UIView? = nil
        
        init( parentView: Content, menu: UIMenu) {
            self.parentView = parentView
            self.menu = menu
        }
        
        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            configurationForMenuAtLocation location: CGPoint
        ) -> UIContextMenuConfiguration? {
            UIContextMenuConfiguration(
                identifier: nil,
                previewProvider: nil,
                actionProvider: { [weak self] _ in
                    guard let self = self else { return nil }
                    return self.menu
                }
            )
        }
        
        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            willDisplayMenuFor configuration: UIContextMenuConfiguration,
            animator: UIContextMenuInteractionAnimating?
        ) {
            view?.isHidden = false
        }
        
        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
            animator: UIContextMenuInteractionCommitAnimating
        ) {
            animator.preferredCommitStyle = .dismiss
        }
        
        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
        ) -> UITargetedPreview? {
            
            let snapshot = UIHostingController(rootView: self.parentView)
            view = snapshot.view
            
            guard
                let view = view,
                let interactionView = interaction.view
            else {
                return nil
            }
            
            view.translatesAutoresizingMaskIntoConstraints = false
            interactionView.addSubview(view)
            view.pinToSuperviewEdges()
            view.isHidden = true
            
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            
            return UITargetedPreview(view: interactionView, parameters: parameters)
        }
        
        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration
        ) -> UITargetedPreview? {
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            interaction.view?.subviews.forEach { $0.removeFromSuperview() }
            return UITargetedPreview(view: interaction.view!, parameters: parameters)
        }
    }
}
