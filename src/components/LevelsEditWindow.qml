import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qt.labs.folderlistmodel

import app

Window {
  required property url levelsMetaFileUrl;
  required property url projectFolderUrl;
  property alias levelsFolderUrl: candidatesModel.folder

  function open() {
    if (FileIO.isExists(root.levelsMetaFileUrl)) {
      const json = FileIO.loadJson(root.levelsMetaFileUrl);
      for (const relativePath of json.levels) {
        const fileUrl = FileIO.absolutePath(root.projectFolderUrl, relativePath);
        levelsModel.addItem(fileUrl);
      }
    }
    root.show();
  }

  id: root
  title: qsTr("Edit levels order")
  modality: Qt.WindowModal
  minimumWidth: 640
  minimumHeight: 480

  FolderListModel {
    id: candidatesModel
    showDirs: false
    nameFilters: "*.level.json"

    function toArray() {
      const result = [];
      const length = candidatesModel.count;
      for (let i = 0; i < length; i++) {
        const fileUrl = candidatesModel.get(i, "fileUrl");
        result.push({ fileUrl });
      }
      return result;
    }
  }

  ListModel {
    property int idCounter: 0

    id: levelsModel

    function addItem(fileUrl: url) {
      levelsModel.append({ id: levelsModel.idCounter, fileUrl });
      levelsModel.idCounter += 1;
    }

    function insertItem(idx: int, fileUrl: url) {
      levelsModel.insert(Math.max(0, idx), { id: levelsModel.idCounter, fileUrl });
      levelsModel.idCounter += 1;
    }

    function toArray(cb) {
      const result = [];
      const length = levelsModel.count;
      for (let i = 0; i < length; i++) {
        result.push(levelsModel.get(i));
      }
      return result;
    }

    function getIndexById(id) {
      return levelsModel.toArray().findIndex((item) => item.id === id);
    }
  }

  component LevelItem: Label {
    property int modelId: (model.id === null || model.id === undefined) ? -1 : model.id
    property url fileUrl: model.fileUrl
    text: fileUrl.toString().replace(root.levelsFolderUrl, "");
    padding: Theme.spacing(0.5)
  }

  Action {
    id: addItemAction
    enabled: candidatesView.currentIndex >= 0
    onTriggered: {
      levelsModel.insertItem(levelsView.currentIndex + 1, candidatesView.currentItem.fileUrl);
    }
  }

  Action {
    id: addAllItemsAction
    enabled: candidatesModel.count > 0
    onTriggered: {
      const insertPosition = Math.max(levelsView.currentIndex, 0);
      candidatesModel
        .toArray()
        .reverse()
        .forEach((item) => {
          levelsModel.insertItem(insertPosition, item.fileUrl);
          levelsView.currentIndex += 1;
        });
    }
  }

  Action {
    id: removeItemAction
    enabled: levelsView.currentIndex >= 0
    onTriggered: {
      if (levelsView.currentIndex >= 0) {
        levelsModel.remove(levelsView.currentIndex, 1);
      }
    }
  }

  Action {
    id: removeAllItemsAction
    enabled: levelsModel.count > 0
    onTriggered: levelsModel.clear()
  }

  Action {
    id: closeAction
    text: qsTr("Cancel")
    onTriggered: root.close()
  }

  Action {
    id: acceptAction
    text: qsTr("Save and close")
    onTriggered: {
      onClicked: {
        const levels = levelsModel
          .toArray()
          .map((value) => value.fileUrl)
          .map((value) => FileIO.relativePath(root.projectFolderUrl, value));
        try {
          FileIO.saveJson(root.levelsMetaFileUrl, { levels });
          root.close();
        } catch(error) {
          console.error(error);
        }
      }
    }
  }

  Pane {
    anchors.fill: parent

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Theme.spacing(1)
      spacing: Theme.spacing(2)

      Item {
        property real buttonsBlockWidth: Theme.spacing(14)
        property real listWidth: (parent.width - buttonsBlockWidth) / 2

        id: layout
        Layout.fillWidth: true
        Layout.fillHeight: true

        GroupBox {
          title: qsTr("Candidates")
          width: layout.listWidth
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.left: parent.left

          ListView {
            id: candidatesView
            anchors.fill: parent
            model: candidatesModel
            focus: true
            highlight: Highlight {}
            clip: true
            delegate: LevelItem {
              MouseArea {
                anchors.fill: parent
                onClicked: candidatesView.currentIndex = index
                onDoubleClicked: addItemAction.trigger()
              }
            }

            ScrollBar.vertical: ScrollBar {
            }
          }
        }

        Item {
          width: layout.buttonsBlockWidth
          anchors.leftMargin: layout.listWidth
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom

          ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Theme.spacing(1)
            spacing: Theme.spacing(1)

            Button {
              Layout.fillWidth: true
              text: qsTr("Add")
              action: addItemAction
            }

            Button {
              Layout.fillWidth: true
              text: qsTr("Add all")
              action: addAllItemsAction
            }

            Button {
              Layout.fillWidth: true
              text: qsTr("Remove")
              action: removeItemAction
            }

            Button {
              Layout.fillWidth: true
              text: qsTr("Remove all")
              action: removeAllItemsAction
            }
          }
        }

        GroupBox {
          title: qsTr("Levels")
          width: layout.listWidth
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.right: parent.right

          ListView {
            id: levelsView
            anchors.fill: parent
            model: levelsModel
            focus: true
            clip: true
            highlight: Highlight {}
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 300
            delegate: LevelItem {
              property var dragStart

              id: item
              Drag.active: dragMouseHandler.drag.active
              Drag.hotSpot.x: width / 2
              Drag.hotSpot.y: height / 2

              MouseArea {
                id: dragMouseHandler
                drag.target: parent
                drag.axis: Drag.YAxis
                anchors.fill: parent
                preventStealing: true
                onPressed: {
                  const { x, y } = item;
                  item.dragStart = { x, y };
                  levelsView.currentIndex = index;
                }
                onReleased: {
                  const { target: dropTarget, hotSpot } = item.Drag;
                  const goBack = () => {
                    item.x = item.dragStart.x;
                    item.y = item.dragStart.y;
                  };
                  if (item.Drag.drop() === Qt.IgnoreAction) {
                    goBack();
                  } else {
                    const dropIndex = levelsModel.getIndexById(dropTarget.parent.modelId);
                    levelsModel.move(index, dropIndex, 1);
                  }
                }
              }

              DropArea {
                anchors.fill: parent
                onDropped: function(drop) {
                  drop.accept(Qt.MoveAction);
                }
              }
            }

            ScrollBar.vertical: ScrollBar {
            }
          }
        }
      }

      FormAcceptButtonsGroup {
        Layout.fillWidth: true
        cancelAction: closeAction
        acceptAction: acceptAction
      }
    }
  }
}
