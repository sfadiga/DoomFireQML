import QtQuick 2.13
import QtQuick.Window 2.13

Window {
    id: root
    visible: true
    width: 100
    height: 100

    FireCanvas {
        id: fireCanvas

        anchors.fill: parent

        renderTarget: Canvas.FramebufferObject //  Canvas.Image //
        renderStrategy: Canvas.Threaded // Canvas.Cooperative //

    }
}
