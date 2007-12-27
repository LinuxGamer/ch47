####    CH47D   ####

aircraft.livery.init("Aircraft/ch47/Models/Liveries", "sim/model/livery/name", "sim/model/livery/index");
Cvolume=props.globals.getNode("/sim/sound/Cvolume",1);
Ovolume=props.globals.getNode("/sim/sound/Ovolume",1);

var FHmeter = aircraft.timer.new("/instrumentation/clock/flight-meter-sec", 10);
FHmeter.stop();

var view_list =[];
var Sview = props.globals.getNode("/sim").getChildren("view");
foreach (v;Sview) {
append(view_list,"sim/view["~v.getIndex()~"]/config/default-field-of-view-deg");
}
aircraft.data.add(view_list);

setlistener("/sim/signals/fdm-initialized", func {
    Cvolume.setValue(0.5);
    Ovolume.setValue(0.2);
    setprop("/instrumentation/clock/flight-meter-hour",0);
    settimer(update_systems,2);
    print("Aircraft Systems ... OK");
});

setlistener("/sim/current-view/view-number", func(vw){
    ViewNum = vw.getValue();
    if(ViewNum == 0){
        Cvolume.setValue(0.5);
        Ovolume.setValue(0.5);
        }else{
        Cvolume.setValue(0.2);
        Ovolume.setValue(1.0);
        }
    },1,0);

setlistener("/gear/gear[1]/wow", func(gw){
    if(gw.getBoolValue()){
    FHmeter.stop();
    }else{
        FHmeter.start();
        }
},0,0);

setlistener("/sim/model/start-idling", func(idle){
    var run= idle.getBoolValue();
    if(run){
    Startup();
    }else{
    Shutdown();
    }
},0,0);

var Startup = func{
setprop("controls/electric/engine[0]/generator",1);
setprop("controls/electric/battery-switch",1);
setprop("controls/lighting/instrument-lights",1);
setprop("controls/lighting/nav-lights",1);
setprop("controls/lighting/beacon",1);
setprop("controls/lighting/strobe",1);
setprop("controls/engines/engine[0]/magnetos",3);
}

var Shutdown = func{
setprop("controls/electric/engine[0]/generator",0);
setprop("controls/electric/battery-switch",0);
setprop("controls/lighting/instrument-lights",0);
setprop("controls/lighting/nav-lights",0);
setprop("controls/lighting/beacon",0);
setprop("controls/engines/engine[0]/magnetos",0);
}

var flight_meter = func{
var fmeter = getprop("/instrumentation/clock/flight-meter-sec");
var fminute = fmeter * 0.016666;
var fhour = fminute * 0.016666;
setprop("/instrumentation/clock/flight-meter-hour",fhour);
}

var update_systems = func {
    flight_meter();
    settimer(update_systems, 0);
}
