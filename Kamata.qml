import QtQuick 2.3
import QtGraphicalEffects 1.0

import "img"

//     __ __                      __       
//    / //_/___ _____ ___  ____ _/ /_____ _
//   / ,< / __ `/ __ `__ \/ __ `/ __/ __ `/
//  / /| / /_/ / / / / / / /_/ / /_/ /_/ / 
// /_/ |_\__,_/_/ /_/ /_/\__,_/\__/\__,_/ 
// 

Item {
    /*#########################################################################
      #############################################################################
      Imported Values From GAWR inits
      #############################################################################
      #############################################################################
     */
    id: root

    ////////// IC7 LCD RESOLUTION ////////////////////////////////////////////
    width: 800
    height: 480
    
    z: 0
    
    property int myyposition: 0
    property int udp_message: rpmtest.udp_packetdata

    property bool udp_up: udp_message & 0x01
    property bool udp_down: udp_message & 0x02
    property bool udp_left: udp_message & 0x04
    property bool udp_right: udp_message & 0x08

    property int membank2_byte7: rpmtest.can203data[10]
    property int inputs: rpmtest.inputsdata

    //Inputs//31 max!!
    property bool ignition: inputs & 0x01
    property bool battery: inputs & 0x02
    property bool lapmarker: inputs & 0x04
    property bool rearfog: inputs & 0x08
    property bool mainbeam: inputs & 0x10
    property bool up_joystick: inputs & 0x20 || root.udp_up
    property bool leftindicator: inputs & 0x40
    property bool rightindicator: inputs & 0x80
    property bool brake: inputs & 0x100
    property bool oil: inputs & 0x200
    property bool seatbelt: inputs & 0x400
    property bool sidelight: inputs & 0x800
    property bool tripresetswitch: inputs & 0x1000
    property bool down_joystick: inputs & 0x2000 || root.udp_down
    property bool doorswitch: inputs & 0x4000
    property bool airbag: inputs & 0x8000
    property bool tc: inputs & 0x10000
    property bool abs: inputs & 0x20000
    property bool mil: inputs & 0x40000
    property bool shift1_id: inputs & 0x80000
    property bool shift2_id: inputs & 0x100000
    property bool shift3_id: inputs & 0x200000
    property bool service_id: inputs & 0x400000
    property bool race_id: inputs & 0x800000
    property bool sport_id: inputs & 0x1000000
    property bool cruise_id: inputs & 0x2000000
    property bool reverse: inputs & 0x4000000
    property bool handbrake: inputs & 0x8000000
    property bool tc_off: inputs & 0x10000000
    property bool left_joystick: inputs & 0x20000000 || root.udp_left
    property bool right_joystick: inputs & 0x40000000 || root.udp_right

    property int odometer: rpmtest.odometer0data/10*0.62 //Need to div by 10 to get 6 digits with leading 0
    property int tripmeter: rpmtest.tripmileage0data*0.62
    property real value: 0
    property real shiftvalue: 0

    property real rpm: rpmtest.rpmdata
    property real rpmlimit: 8000 
    property real rpmdamping: 5
    property real speed: rpmtest.speeddata
    property int speedunits: 2

    property real watertemp: rpmtest.watertempdata
    property real waterhigh: 0
    property real waterlow: 80
    property real waterunits: 1

    property real fuel: rpmtest.fueldata
    property real fuelhigh: 0
    property real fuellow: 0
    property real fuelunits
    property real fueldamping

    property real o2: rpmtest.o2data
    property real map: rpmtest.mapdata
    property real maf: rpmtest.mafdata

    property real oilpressure: rpmtest.oilpressuredata
    property real oilpressurehigh: 0
    property real oilpressurelow: 0
    property real oilpressureunits: 0

    property real oiltemp: rpmtest.oiltempdata
    property real oiltemphigh: 90
    property real oiltemplow: 90
    property real oiltempunits: 1
    property real oiltemppeak: 0

    property real batteryvoltage: rpmtest.batteryvoltagedata

    property int mph: (speed * 0.62)

    property int gearpos: rpmtest.geardata

    property real speed_spring: 1
    property real speed_damping: 1

    property real rpm_needle_spring: 3.0 //if(rpm<1000)0.6 ;else 3.0
    property real rpm_needle_damping: 0.2 //if(rpm<1000).15; else 0.2

    property bool changing_page: rpmtest.changing_pagedata


    property string white_color: "#FFFFFF"
    property string primary_color: "#ADE6FF" //#FFBF00 for amber
    property string lit_primary_color: "#F59713" //lit orange
    property string warning_color: "#FF1100" //Warning Red
    property string tachbar: "#FF0000"
    property string engine_warmup_color: "#eb7500"
    property string background_color: "#000000"
    property string bar_directory: ""

    property int timer_time: 1

    //Peak Values

    property int peak_rpm: 0
    property int peak_speed: 0
    property int peak_water: 0
    property int peak_oil: 0
    property bool car_movement: false
    x: 0
    y: 0

    FontLoader {
        id: dESGlightitalicMONO
        source: "./fonts/DSEG14Classic-LightItalicMONO.ttf"
    }
    FontLoader{
        id: boosted
        source: "./fonts/BoostedRegular.ttf"
    }

    //For our Oil/Water Temperatures
    function getBarSource(src){
        if(root.sidelight){ bar_directory = "bars_lit"} 
        if(!root.sidelight){ bar_directory = "bars_unlit"}
        if(src === "OIL"){
            return './kamata/'+ bar_directory + '/'+ Math.min(Math.max(0,Math.round((getTemp(src))/10)),15) + '.png'
        }
        else{
            return './kamata/'+ bar_directory + '/'+Math.min(Math.max(0,(Math.round(getTemp(src)*.125))),15) + '.png'
        }
    }

    //Master Function/Timer for Peak values
    function checkPeaks(){
        if(root.rpm > root.peak_rpm){
            root.peak_rpm = root.rpm
        }
        if(root.speed > root.peak_speed){
            root.peak_speed = root.speed
        }
        if(root.watertemp > root.peak_water){
            root.peak_water = root.watertemp
        }
        if(root.oiltemp > root.peak_oil){
            root.peak_oil = root.oiltemp
        }
        if(root.speed > 10 && !root.car_movement){
            root.car_movement = true
        }
    }
   
    //Utility  stuff  
    function easyFtemp(degreesC){
        return ((((degreesC.toFixed(0))*9)/5)+32).toFixed(0)
    }
    
    function getPeakSpeed(){
        if (root.speedunits === 0) return root.peak_speed.toFixed(0); else return (root.peak_speed*.62).toFixed(0)
    }

    function getTemp(fluid){
        if(fluid == "COOLANT"){
            if(root.seatbelt && root.car_movement && root.speed === 0){ 
                 if(root.waterunits !== 0)
                    return easyFtemp(root.peak_water)
                else 
                    return root.peak_water.toFixed(0)
            }
            else{
                if(root.waterunits !== 0)
                    return easyFtemp(root.watertemp)
                else 
                    return root.watertemp.toFixed(0)
            }
        }
        else{
            if(root.seatbelt && root.car_movement && root.speed === 0){
                 if(root.oiltempunits !== 0)
                    return easyFtemp(root.peak_oil)
                else 
                    return root.peak_oil.toFixed(0)
            }
            else{
                if(root.oiltempunits !== 0)
                    return easyFtemp(root.oiltemp)
                else 
                    return root.oiltemp.toFixed(0)
            }
        }
    }
    function tempColors(fluid){
        if((fluid === 'COOLANT' && root.watertemp >= root.waterhigh) || (fluid === 'OIL' && root.oiltemp >= root.oiltemphigh)){
            return root.warning_color
        }
        else{
            if(root.sidelight){
                return root.lit_primary_color
            }
            else{
                return root.primary_color
            }
        }
    }
    //Master Timer 
    Timer{
        interval: 2; running: true; repeat: true //Maybe we need to change interval time depending on potential lag, shouldn't be that much though
        onTriggered: checkPeaks()
    }

    /* ########################################################################## */
    /* Main Layout items */
    /* ########################################################################## */
    Rectangle {
        id: background_rect
        x: 0
        y: 0
        width: 800
        height: 480
        color: root.background_color
        border.width: 0
        z: 0
    }

    Item{
        z:1
        x:0; y:0
        width: 800
        height: 480
        Image{
            source: './kamata/bkg_img.png'
        }
    }

    Image{
        id: tach_speed_bkg
        z:2
        x: 2; y: 44
        width: 395
        height: 394
        source: './kamata/tach_bkg.png'
    }
    Image{
        id: info_bkg
        z:2
        x: 402; y: 44
        width: 394
        height: 394
        source: './kamata/info_bkg.png'
    }

    Image{
        id: shift_light
        z: 3
        x: 188.3; y: 112.5
        width: 23
        height: 23
        source: './kamata/shiftlight_base.png'
    }

    Image{
        id: shift_light_blink
        z: 3
        x: 168.3; y: 94.5
        width: 61
        height: 60
        source: './kamata/shiftlight_lit.png'
        visible: if(root.rpm >= root.rpmlimit) true; else false
        Timer{
            id: rpm_shift_blink
            running: true
            interval: 50
            repeat: true
            onTriggered: if(parent.opacity === 0){
                parent.opacity = 100
            }
            else{
                parent.opacity = 0
            } 
        }
    }

    Image{
        id: tach_indicators
        z: 3
        x: 16; y: 56.5
        width: 366
        height: 350
        source: if(!root.sidelight) './kamata/tachometer_unlit.png'; else './kamata/tachometer_lit.png'
    }
    
    Image{
        id: tach_needle
        z: 5
        x: 189; y: 73
        width: 17; height: 191
        source: './kamata/needle_pointer.png'
        transform:[
                Rotation {
                    id: tachneedle_rotate
                    origin.y: 166.5
                    origin.x: 8.5
                    angle: if(root.rpm <= 1000){
                            Math.min(Math.max(-155, Math.round((root.rpm/1000)*13.5) - 155), 90)
                        }   
                        else{
                            Math.min(Math.max(-168, Math.round((root.rpm/1000)*26) - 168), 90)
                        }                
                    Behavior on angle{
                        SpringAnimation {
                            spring: 1.2
                            damping:.16
                        }
                    }
                }
            ]
            
    }
    DropShadow {
        z: 4
        anchors.fill: tach_needle
        horizontalOffset: 2
        verticalOffset: 2
        radius: 15
        antialiasing: true
        samples: 16
        color: "#000000"
        source: tach_needle
        cached: true  //Save us some rendering
        transform:[
            Rotation {
                id: shadowneedleRotation
                origin.y: 166.5
                origin.x: 8.5
                angle: if(root.rpm <= 1000){
                        Math.min(Math.max(-155, Math.round((root.rpm/1000)*13.5) - 155), 90)
                    }   
                    else{
                        Math.min(Math.max(-168, Math.round((root.rpm/1000)*26) - 168), 90)
                    }                
                Behavior on angle{
                    SpringAnimation {
                        spring: 1.2
                        damping:.16
                    }
                }
            }
        ]
    }   
    
    Image{
        id: needle_center
        z: 5
        x: 182; y: 224
        height: 33; width: 33
        source: './kamata/needle_base.png'
    }
    Image{
        id: speed_bkg
        z: 3
        x: 160; y: 337
        height: 82; width: 162
        source: './kamata/speed_display.png'
    }
    Text{
        id: speed_text_bkg
        x: 177; y: 346; z: 4
        font.family: dESGlightitalicMONO.name
        font.pixelSize: 60
        color: "#220000"
        width: 140
        text: "~~~"
        horizontalAlignment: Text.AlignRight
    }
    Item{
        z:5
        property string speedtext: if(root.peak_speed === 0) "** PUSH 1P START **"; else "Peak Speed "+ getPeakSpeed() + "    Peak RPM " + root.peak_rpm
        property string spacing: "   "
        property string combined: speedtext + spacing
        property string display: combined.substring(step) + combined.substring(0, step)
        property int step: 0

        Timer {
            interval: 250
            running: true
            repeat: true
            onTriggered: parent.step = (parent.step + 1) % parent.combined.length
        }
        Text{
            id: speed_text
            x: 173; y: 346; z: 5
            font.family: dESGlightitalicMONO.name
            font.pixelSize: 60
            color: if(!root.sidelight) "#C83515"; else "#FF6665"
            width: 145
            height: 100;
            clip: true
            text: if((root.speed === 0 && !root.car_movement && root.rpm === 0) || (root.speed === 0 && root.seatbelt)){
                    parent.display
                }
                else{
                    if (root.speedunits === 0) root.speed.toFixed(0); else (root.speed*.62).toFixed(0)
                }
            horizontalAlignment: Text.AlignRight
        }
    }
    
    Image{
        id: speed_label
        x: 323; y: 403; z: 5
        source: if(!root.sidelight){
                if(root.speedunits === 0) './kamata/km_unlit.png'; else './kamata/mi_unlit.png'
            }
            else{
                if(root.speedunits === 0) './kamata/km_lit.png'; else './kamata/mi_lit.png'
            }
    }

    //Blinkers
    Image{
        x: 355; y:60; z:4
        source: if(!root.leftindicator) './kamata/left_signal_unlit.png'; else './kamata/left_signal_lit.png'
    }
    Image{
        x: 400; y:60; z:4
        source: if(!root.rightindicator) './kamata/right_signal_unlit.png'; else './kamata/right_signal_lit.png'
    }

    //Bottom Row
    Image{
        x: 477; y: 120; z:4
        source: './kamata/warnings/srs.png'
        visible: root.airbag
        
    }
    Image{
        x: 514; y: 120; z:4
        source: './kamata/warnings/oil.png'
        visible: root.oil
    }
    Image{
        x: 574; y: 124; z:4
        source: './kamata/warnings/brake.png'
        visible: root.brake
    }
    Image{
        x: 634; y: 124; z:4
        source: './kamata/warnings/abs.png'
        visible: root.abs
    }
    Image{
        x: 674; y: 120; z:4
        source: './kamata/warnings/door.png'
        visible: root.doorswitch
    }    
    Image{
        x: 704; y: 120; z:4
        source: './kamata/warnings/seatbelt.png'
        visible: root.seatbelt
    }    
    //Top Row
    Image{
        x: 510; y: 80; z: 4
        source: './kamata/warnings/battery.png'
        visible: root.battery
    }
    Image{
        x: 550; y: 80; z: 4
        source: './kamata/warnings/checkengine.png'
        visible: root.mil
    }
    Image{
        x: 595; y: 80; z: 4
        source: './kamata/warnings/sidelights.png'
        visible: root.sidelight
    }
    Image{
        x: 645; y: 80; z: 4
        source: './kamata/warnings/brights.png'
        visible: root.mainbeam
    }
    
    Image{
        id: oil_temp_bars
        x: 460; y: 210; z: 4
        source: getBarSource('OIL')
        opacity:0;
        Timer{
            interval: 1000; running: root.ignition; repeat: false
            onTriggered:  animateOilBars.start()
        }

    }
    Text{
        id: oil_temp_number
        x:485; y:270; z: 4
        width: 100
        font.pixelSize: 24
        text: getTemp("OIL")
        color: tempColors("OIL")
        font.family: boosted.name
        horizontalAlignment: Text.AlignRight
        opacity:0;
        Timer{
            interval: 2000; running: root.ignition; repeat: false
            onTriggered: animateOilNumbers.start()
        }
    }
    Image{ 
        id: oil_temp_label
        x: 513; y: 310; z:4
        opacity:0
        source: if(root.oiltemp >= root.oiltemphigh) './kamata/oiltemp_red.png'; else{if(!root.sidelight) './kamata/oiltemp_unlit.png'; else './kamata/oiltemp_lit.png'}
        Timer{
            interval: 1500; running: root.ignition; repeat: false
            onTriggered: animateOilLabel.start()
        }
    }
    
    SequentialAnimation{
        id: animateOilBars
        NumberAnimation{
            target: oil_temp_bars; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }
    SequentialAnimation{
        id: animateOilNumbers
        NumberAnimation{
            target: oil_temp_number; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }
    SequentialAnimation{
        id: animateOilLabel
        NumberAnimation{
            target: oil_temp_label; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }

    Image{
        id: water_temp_bars
        x: 590; y: 210; z: 4
        source: getBarSource('COOLANT')
        opacity:0
        Timer{
            interval: 2500; running: root.ignition; repeat: false
            onTriggered:  animateWaterBars.start()
        }
    }
    SequentialAnimation{
        id: animateWaterBars
        NumberAnimation{
            target: water_temp_bars; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }
    Text{
        id: water_temp_numbers
        x:625; y:270; z: 4
        font.pixelSize: 24
        width: 100
        text: getTemp("COOLANT")
        color: tempColors("COOLANT")
        font.family: boosted.name
        opacity:0
        horizontalAlignment: Text.AlignRight
        Timer{
            interval: 3500; running: root.ignition; repeat: false
            onTriggered: animateWaterNumbers.start()
        }
    }
   
    Image{ 
        id: water_temp_label
        x: 622; y: 311; z:4
        source: if(root.watertemp >= root.waterhigh) './kamata/watertemp_red.png'; else{if(!root.sidelight) './kamata/watertemp_unlit.png'; else './kamata/watertemp_lit.png'}
        opacity:0
        Timer{
            interval: 3000; running: root.ignition; repeat: false
            onTriggered: animateWaterLabel.start()
        }
    }
     SequentialAnimation{
        id: animateWaterNumbers
        NumberAnimation{
            target: water_temp_numbers; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }
    SequentialAnimation{
        id: animateWaterLabel
        NumberAnimation{
            target: water_temp_label; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }


    Text{
        id: oil_pressure_numbers
        x:580; y:167; z: 4
        font.pixelSize: 14
        width: 100
        opacity: 0
        text: root.oilpressure.toFixed(1)
        color: if(!root.sidelight) root.primary_color; else root.lit_primary_color
        font.family: boosted.name
        horizontalAlignment: Text.AlignRight
        Timer{
            interval: 1000; running: root.ignition; repeat: false
            onTriggered: animateOilPressureNumbers.start()
        }
    }
    Image{
        id: oil_pressure_label
        x:510; y: 170; z:4
        source: if(!root.sidelight) './kamata/oilpressure_unlit.png'; else './kamata/oilpressure_lit.png'
        opacity:0
        Timer{
            interval: 750; running: root.ignition; repeat: false
            onTriggered: animateOilPressureLabel.start()
        }
    }
    SequentialAnimation{
        id: animateOilPressureNumbers
        NumberAnimation{
            target: oil_pressure_numbers; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }   
    SequentialAnimation{
        id: animateOilPressureLabel
        NumberAnimation{
            target: oil_pressure_label; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }   
    Rectangle{
        id: oil_pressure_splitter
        color: if(!root.sidelight) root.primary_color; else root.lit_primary_color
        x: 430; y: 195; z: 4
        height: 1; width: 337
        opacity: 0
        Timer{
                    interval: 500; running: root.ignition; repeat: false
                    onTriggered: animateOilPressureSplitter.start()
            }
    }
    SequentialAnimation{
        id: animateOilPressureSplitter
        NumberAnimation{
            target: oil_pressure_splitter; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }
    Item{
        id: fuel_system
        z: 9
        opacity: 0
        Image{
            x: 514; y: 352
            source: if(!root.sidelight) './kamata/e_unlit.png'; else './kamata/e_lit.png'
        }
        Image{
            x: 659; y: 352
            source: if(!root.sidelight) './kamata/f_unlit.png'; else './kamata/f_lit.png'
        }
        Item {
            id: fuel_bars
            x: 534; y: 352
            width: 128; height: 32
            Row {
                id: gasgauge
                x: 0; y: -8
                width: 128
                height: 32
                antialiasing: true
                z: 3
                Repeater {
                    model: 20
                    property int index
                    Row {
                        Rectangle {
                            width: 4
                            height: 22
                            color: if (root.fuel > root.fuellow)
                                        if(!root.sidelight) root.primary_color; else root.lit_primary_color
                                    else
                                        root.warning_color
                            radius: 2
                            z: 1
                            opacity: if (Math.floor(root.fuel / 5) >= index) 1; else .1
                        }
                        Rectangle {
                            width: 2
                            height: 22
                            color: root.background_color
                            z: 1
                        }
                    }
                }
            }
        }
        Timer{
                interval: 1000; running: root.ignition; repeat: false
                onTriggered: animateFuelSystem.start()
            }
    }
    SequentialAnimation{
        id: animateFuelSystem
        NumberAnimation{
            target: fuel_system; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }

    Item{
        id: fuel_divider
        opacity: 0;
        z: 9
        Rectangle{
            id: divider
            x: 534; y: 370
            height: 1; width: 118
            color: if(!root.sidelight) root.primary_color; else root.lit_primary_color
        }
        Rectangle{
            id: e_divider
            x: 534; y: 370
            height: 4; width: 1
            color: if(!root.sidelight) root.primary_color; else root.lit_primary_color
        }
        Rectangle{
            id: m_divider
            x: 592; y: 370
            height: 4; width: 1
            color: if(!root.sidelight) root.primary_color; else root.lit_primary_color
        }
        Rectangle{
            id: f_divider
            x: 652; y: 370
            height: 4; width: 1
            color: if(!root.sidelight) root.primary_color; else root.lit_primary_color
        }
        Timer{
                interval: 500; running: root.ignition; repeat: false
                onTriggered: animateFuelDivider.start()
            }
    }
     SequentialAnimation{
        id: animateFuelDivider
        NumberAnimation{
            target: fuel_divider; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }

    Text{
        id: mileage
        x: 525; y: 385; z:9
        opacity: 0;
        color: if(!root.sidelight) root.primary_color; else root.lit_primary_color
        text: if (root.speedunits === 0)
                        (root.odometer/.62).toFixed(0) 
                    else if(root.speedunits === 1)
                        root.odometer 
                    else
                        root.odometer
        font.family: boosted.name
        font.pixelSize: 14
        width: 128
        horizontalAlignment: Text.AlignRight
        Timer{
                interval: 1500; running: root.ignition; repeat: false
                onTriggered: animateMileage.start()
            }
    }
    SequentialAnimation{
        id: animateMileage
        NumberAnimation{
            target: mileage; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }

    
} //End Kamata Item



