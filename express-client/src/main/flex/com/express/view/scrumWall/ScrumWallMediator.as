package com.express.view.scrumWall {
import com.express.ApplicationFacade;
import com.express.controller.IterationLoadCommand;
import com.express.controller.ProjectLoadCommand;
import com.express.model.ProjectProxy;
import com.express.model.SecureContextProxy;
import com.express.model.WallProxy;

import com.express.model.domain.BacklogItem;

import com.express.model.domain.Issue;
import com.express.view.backlogItem.BacklogItemMediator;
import com.express.view.backlogItem.BacklogItemProxy;
import com.express.view.renderer.CardView;

import mx.collections.ArrayCollection;

import mx.events.FlexEvent;

import org.puremvc.as3.interfaces.INotification;
import org.puremvc.as3.patterns.mediator.Mediator;

public class ScrumWallMediator extends Mediator {
   public static const NAME:String = "com.express.view.scrumWall.ScrumWallMediator";

   private var _wallProxy : WallProxy;
   private var _projectProxy : ProjectProxy;
   private var _backlogItemProxy : BacklogItemProxy;
   private var _secureContext : SecureContextProxy;
   private var _defaultSwimLaneWidth : int;

   public function ScrumWallMediator(viewComp : ScrumWallView) {
      super(NAME, viewComp);
      _wallProxy = WallProxy(facade.retrieveProxy(WallProxy.NAME));
      _projectProxy = ProjectProxy(facade.retrieveProxy(ProjectProxy.NAME));
      _backlogItemProxy = BacklogItemProxy(facade.retrieveProxy(BacklogItemProxy.NAME));
      _secureContext = SecureContextProxy(facade.retrieveProxy(SecureContextProxy.NAME));
      viewComp.rptStories.dataProvider = _wallProxy.currentBacklog;
      _defaultSwimLaneWidth = (viewComp.width - 220) / 4;
      viewComp.openLane.width = _defaultSwimLaneWidth;
      viewComp.progressLane.width = _defaultSwimLaneWidth;
      viewComp.testLane.width = _defaultSwimLaneWidth;
      viewComp.doneLane.width = _defaultSwimLaneWidth;
      loadIterationBacklog();
   }

   override public function listNotificationInterests():Array {
      return [IterationLoadCommand.SUCCESS,
              ApplicationFacade.NOTE_LOAD_BACKLOG_COMPLETE,
              ApplicationFacade.NOTE_REMOVE_BACKLOG_ITEM,
              ProjectLoadCommand.SUCCESS,
              StoryCard.NOTE_ADD_TASK,
              StoryCard.NOTE_MARK_DONE,
              CardView.NOTE_IMPEDED,
              CardView.NOTE_VIEW_IMPEDIMENT,
              CardView.NOTE_UNIMPEDED,
              CardView.NOTE_UNASSIGN_TASK,
              CardView.NOTE_TAKE_TASK];
   }

   override public function handleNotification(notification:INotification):void {
      switch (notification.getName()) {
         case IterationLoadCommand.SUCCESS :
            loadIterationBacklog();
            break;
         case ApplicationFacade.NOTE_LOAD_BACKLOG_COMPLETE :
               if(_projectProxy.selectedIteration) {
                  _wallProxy.currentBacklog = _projectProxy.selectedIteration.backlog;
               }
            break;
         case ApplicationFacade.NOTE_REMOVE_BACKLOG_ITEM :
            _wallProxy.removeBacklogItem(notification.getBody() as BacklogItem);
            break;
         case ProjectLoadCommand.SUCCESS :
            loadIterationBacklog();
            break;
         case StoryCard.NOTE_MARK_DONE :
            sendNotification(ApplicationFacade.NOTE_MARK_DONE_BACKLOG_ITEM, BacklogItem(notification.getBody()).id);
            break;
         case StoryCard.NOTE_ADD_TASK :
            var item : BacklogItem = new BacklogItem();
            item.parent = BacklogItem(notification.getBody());
            sendNotification(BacklogItemMediator.CREATE, item);
            break;
         case CardView.NOTE_IMPEDED :
            _backlogItemProxy.currentBacklogItem = BacklogItem(notification.getBody());
            _backlogItemProxy.currentIssue = new Issue();
            _backlogItemProxy.currentIssue.startDate = new Date();
            _backlogItemProxy.currentIteration = _projectProxy.selectedIteration;
            sendNotification(ApplicationFacade.NOTE_CREATE_IMPEDIMENT);
            break;
         case CardView.NOTE_VIEW_IMPEDIMENT :
            _backlogItemProxy.currentBacklogItem = BacklogItem(notification.getBody());
            _backlogItemProxy.currentIssue = _backlogItemProxy.currentBacklogItem.impediment;
            sendNotification(ApplicationFacade.NOTE_EDIT_IMPEDIMENT);
            break;
         case CardView.NOTE_UNIMPEDED :
            var unimpeded : BacklogItem = BacklogItem(notification.getBody());
            sendNotification(ApplicationFacade.NOTE_REMOVE_IMPEDIMENT, unimpeded);
            break;
         case CardView.NOTE_TAKE_TASK :
            var taken : BacklogItem = BacklogItem(notification.getBody());
            taken.assignedTo = _secureContext.currentUser;
            sendNotification(ApplicationFacade.NOTE_UPDATE_BACKLOG_ITEM, taken);
            break;
         case CardView.NOTE_UNASSIGN_TASK :
            var unassigned : BacklogItem = BacklogItem(notification.getBody());
            unassigned.assignedTo = null;
            sendNotification(ApplicationFacade.NOTE_UPDATE_BACKLOG_ITEM, unassigned);
            break;
      }
   }

   private function loadIterationBacklog() : void {
      if (_projectProxy.selectedIteration != null && _projectProxy.selectedIteration.id != -1) {
         _wallProxy.currentBacklog = _projectProxy.selectedIteration.backlog;
      }
      else {
         _wallProxy.currentBacklog = new ArrayCollection();
      }
   }
}
}