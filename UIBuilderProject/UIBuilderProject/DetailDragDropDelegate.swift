//
//  DetailDragDropDelegate.swift
//  UIBuilderProject
//
//  Created by Justin Havas on 4/1/20.
//  Copyright © 2020 DeviceUIBuilder. All rights reserved.
//
// This extension is used to maintain all the drag and drop code within the DetailViewController.

import UIKit

extension DetailViewController: UIDragInteractionDelegate, UIDropInteractionDelegate {
   // MARK: - Drag
    
    /*
    This method begins a UIDragSession from the dropView.
    */
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let dragLocation = session.location(in: dropView!)
        draggedView = getViewBeingDragged(dragLocation: dragLocation)
        guard let string = ActionViewUtilities.getStringFromView(view: draggedView) else { return [] }
        clearUpAlignments()
        let provider = NSItemProvider(object: string as NSString)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = string
        return [item]
    }
    
    /*
    This method attempts to determine the view starting the UIDragSession.
    */
    func getViewBeingDragged(dragLocation: CGPoint) -> UIView? {
        for subview in dropView!.subviews {
            if subview.frame.contains(dragLocation) {
                return subview
            }
        }
        return nil
    }
    
    // MARK: - Drop
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.items.count == 1
    }
    
    /*
    This method determines whether the user is hovering over a valid location to drop onto the dropView.
    */
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let dropLocation = session.location(in: dropView!)
        let operation: UIDropOperation
        
        findAlignments(dropLocation: dropLocation)
        
        if !doesOverlapOtherViews(dropLocation: dropLocation) {
            /*
                 If you add in-app drag-and-drop support for the .move operation,
                 you must write code to coordinate between the drag interaction
                 delegate and the drop interaction delegate.
            */
            operation = session.localDragSession == nil ? .copy : .move
        } else {
            // Do not allow dropping outside of the image view.
            operation = .cancel
        }
        return UIDropProposal(operation: operation)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        clearUpAlignments()
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
        clearUpAlignments()
    }
    
    /*
    This method is called when a the user performs a valid drop.
    */
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        let dropLocation = session.location(in: dropView!)
        // Consume drag items (in this example, of type UIImage).
        session.loadObjects(ofClass: NSString.self) { stringItems in
            let strings = stringItems as! [NSString]

            /*
                 If you do not employ the loadObjects(ofClass:completion:) convenience
                 method of the UIDropSession class, which automatically employs
                 the main thread, explicitly dispatch UI work to the main thread.
                 For example, you can use `DispatchQueue.main.async` method.
            */
            
            // grab associatedLabel and name if exists
            let associatedLabel = (self.draggedView as? DragDropView)?.associatedLabel.text ?? ""
            let name = (self.draggedView as? DragDropView)?.name ?? ""
            
            // create new view to replace old one and center it based off alignments and its own width and height.
            let buildView = self.builder.getInstantiation(draggedType: strings.first! as String,theLabel: associatedLabel,name: name,dropViewFrame: self.dropView?.frame)
            buildView.frame = CGRect(x: (self.alignments.x ?? dropLocation.x) - buildView.frame.width/2, y: (self.alignments.y ?? dropLocation.y) - buildView.frame.height/2, width: buildView.frame.width, height: buildView.frame.height)
            
            // add necessary properties in order to further interact with it either through drag and drop or tap gesture
            buildView.addInteraction(UIDragInteraction(delegate: self))
            buildView.isUserInteractionEnabled = true
            self.addTapGesture(thisView: buildView)
            
            self.removePreviousSubViewIfExists()
            self.clearUpAlignments()
            self.dropView?.addSubview(buildView)
            self.builder.edit(buildView, name, associatedLabel)
        }
    }
    
    /*
    This method calculates the vertical and horizontal alignments for the view currently
    being dragged dynamically.
    */
    func findAlignments(dropLocation: CGPoint) {
        clearUpAlignments()
        for subview in dropView!.subviews {
            let halfWidth: CGFloat = subview.frame.width/2
            let halfHeight: CGFloat = subview.frame.height/2
            // don't draw alignment line with self
            if subview.description != draggedView?.description {
                if subview.center.x-halfWidth <= dropLocation.x && subview.center.x+halfWidth >= dropLocation.x {
                    alignments = (x: subview.center.x,y: alignments.y)
                }
                if subview.center.y-halfHeight <= dropLocation.y && subview.center.y+halfHeight >= dropLocation.y {
                    alignments = (x: alignments.x,y: subview.center.y)
                }
            }
        }
        addAlignmentToView(alignOrNil: alignments.x, typeX: true)
        addAlignmentToView(alignOrNil: alignments.y, typeX: false)
    }
    
    /*
    This method draws the alignment line and adds it to the dropView.
    */
    func addAlignmentToView(alignOrNil: CGFloat?,typeX: Bool) {
        if let align = alignOrNil {
            UIGraphicsBeginImageContextWithOptions(dropView!.frame.size, false, 0.0)
            let blueColor = UIColor.blue
            let verticalLine:UIBezierPath = UIBezierPath()
            let start = typeX ? CGPoint(x: align, y: 0) : CGPoint(x: 0, y: align)
            let end = typeX ? CGPoint(x: align, y: dropView!.frame.height) : CGPoint(x: dropView!.frame.width, y: align)
            verticalLine.move(to: start)
            verticalLine.addLine(to: end)
            blueColor.set()
            verticalLine.stroke()
            let verticalAlign:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            let image = UIImageView(image: verticalAlign)
            lines.append(image)
            dropView?.addSubview(image)
        }
    }
    
    /*
    This method clears up all the alignments on the screen and resets alignment variables.
    */
    func clearUpAlignments() {
        for line in lines {
            line.removeFromSuperview()
        }
        lines = []
        alignments = (x: nil,y: nil)
    }
    
    /*
    This method determines whether the draggedView overlaps with other views in the
    dropView at a given location.
    */
    func doesOverlapOtherViews(dropLocation: CGPoint) -> Bool {
        let width: CGFloat = (draggedView?.frame.width)!
        let height: CGFloat = (draggedView?.frame.height)!
        for subview in dropView!.subviews {
            // only allow image to overlap with self and no one else
            if subview.description != draggedView?.description && !lines.contains(subview) && (subview.frame.contains(dropLocation)
                || subview.frame.contains(CGPoint(x: dropLocation.x + width/2, y: dropLocation.y))
                || subview.frame.contains(CGPoint(x: dropLocation.x - width/2, y: dropLocation.y))
                || subview.frame.contains(CGPoint(x: dropLocation.x, y: dropLocation.y + height/2))
                || subview.frame.contains(CGPoint(x: dropLocation.x, y: dropLocation.y - height/2))) {
                return true
            }
        }
        return false
    }
    
    /*
    This method removes the draggedView if it exists.
    */
    func removePreviousSubViewIfExists() {
        for subview in dropView!.subviews {
            if subview.description == draggedView?.description {
                subview.removeFromSuperview()
                builder.delete(subview)
                return
            }
        }
        // reset dragged item
        draggedView = nil
    }

}
