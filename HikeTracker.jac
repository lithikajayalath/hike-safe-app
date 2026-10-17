import from "@jac/mobui" { View, Text, Pressable, Platform }
import from .theme { buildStyles, LIGHT }
glob styles = buildStyles(LIGHT);

def:pub HikeTracker() -> JsxElement {
    has status: str = "Ready. Location permission will be requested only when tracking starts.",
        tracking: bool = False, paused: bool = False, sharing: bool = False,
        latitude: str = "", longitude: str = "", accuracy: str = "",
        startMs: float = 0.0, elapsedSec: float = 0.0, distanceKm: float = 0.0,
        route: list[dict] = [], lastUpdate: str = "Not updated", watchHandle: any = None;
    nowMs = (new(Date).getTime() as float);
    elapsed = elapsedSec;
    if startMs > 0.0 and tracking and not paused { elapsed = (nowMs - startMs) / 1000.0; }
    totalSeconds: int = int(elapsed);
    hours: int = int(totalSeconds / 3600);
    minutes: int = int((totalSeconds - hours * 3600) / 60);
    seconds: int = totalSeconds - hours * 3600 - minutes * 60;
    durationText = str(hours) + ":" + ("0" + str(minutes) if minutes < 10 else str(minutes)) + ":" + ("0" + str(seconds) if seconds < 10 else str(seconds));

    def startTracking {
        if Platform.OS == "web" {
            if navigator and navigator.geolocation {
                geo: any = navigator.geolocation;
                watch = geo.watchPosition(
                    lambda (pos: any) {
                        currentLat = pos.coords.latitude as float;
                        currentLon = pos.coords.longitude as float;
                        accuracy = str(round(pos.coords.accuracy as float)) + " m";
                        if len(route) > 0 {
                            prior = route[len(route) - 1];
                            priorLat = prior["lat"] as float;
                            priorLon = prior["lon"] as float;
                            latDelta: float = currentLat - priorLat;
                            lonDelta: float = currentLon - priorLon;
                            latSpan = latDelta if latDelta >= 0.0 else 0.0 - latDelta;
                            lonSpan = lonDelta if lonDelta >= 0.0 else 0.0 - lonDelta;
                            segmentKm: float = (latSpan + lonSpan) * 55.5;
                            if segmentKm < 1.0 { distanceKm = (distanceKm as float) + segmentKm; }
                        }
                        route = route + [{"lat": currentLat, "lon": currentLon}];
                        latitude = str(currentLat);
                        longitude = str(currentLon);
                        tracking = True;
                        paused = False;
                        if startMs <= 0.0 { startMs = new(Date).getTime() as float; }
                        lastUpdate = str(pos.timestamp);
                        status = "GPS fix received. Foreground tracking active.";
                    },
                    lambda (_error: any) { tracking = False; status = "Location permission denied or GPS unavailable. No coordinates were recorded."; },
                    {"enableHighAccuracy": True, "maximumAge": 0, "timeout": 15000}
                );
                watchHandle = watch;
                status = "Waiting for GPS permission and a real location fix…";
            } else { status = "Geolocation is unavailable in this browser. Tracking did not start."; }
        } else { status = "Device GPS tracking is unavailable on this platform build. Tracking did not start."; }
    }
    def stopWatch {
        if watchHandle and Platform.OS == "web" and navigator and navigator.geolocation {
            geo: any = navigator.geolocation;
            geo.clearWatch(watchHandle);
            watchHandle = None;
        }
    }
    def pauseTracking { stopWatch(); paused = True; tracking = False; elapsedSec = elapsed; status = "Tracking paused. GPS updates have stopped."; }
    def stopTracking { stopWatch(); paused = False; tracking = False; sharing = False; elapsedSec = elapsed; status = "Session stopped. Route remains in memory only and is not uploaded."; }
    def shareLocation {
        if latitude and longitude {
            nav: any = navigator;
            shareText = "My hiking coordinates: " + latitude + ", " + longitude;
            if nav.share { nav.share({"title": "Hiking location", "text": shareText}); sharing = True; status = "Device share sheet opened. Coordinates are shared only if you select a recipient."; }
            elif nav.clipboard { nav.clipboard.writeText(shareText); sharing = True; status = "Coordinates copied. No public link was created."; }
            else { status = "Native sharing and clipboard are unavailable."; }
        } else { status = "No current GPS fix to share."; }
    }
    def copyCoordinates {
        if latitude and longitude {
            nav: any = navigator;
            if nav.clipboard { nav.clipboard.writeText(latitude + ", " + longitude); status = "Current coordinates copied for emergency use."; }
            else { status = "Clipboard is unavailable."; }
        } else { status = "No current GPS fix to copy."; }
    }
    def stopSharing { sharing = False; status = "Sharing stopped. No public link or ongoing share is active."; }

    speedText = "Unavailable";
    if elapsed > 0.0 { speedText = str(round(distanceKm / (elapsed / 3600.0), 2)) + " km/h"; }
    return <View style={{"gap": 16}}>
        <Text style={styles.eyebrow}>FOREGROUND GPS ONLY</Text><Text style={styles.title}>Hiking tracker</Text>
        <View style={styles.notice}><Text style={styles.noticeText}>Your location stays private. Sharing uses the device share sheet or coordinate copy. No public link or background tracking.</Text></View>
        <View style={styles.card}>
            <Text style={styles.sectionTitle}>{"Sharing active" if sharing else ("Tracking paused" if paused else ("Tracking active" if tracking else "Ready to start"))}</Text><Text style={styles.body}>{status}</Text>
            <Text style={styles.factLabel}>Current GPS coordinates</Text><Text style={styles.factValue}>{latitude + ", " + longitude if latitude and longitude else "Unavailable"}</Text>
            <Text style={styles.factLabel}>Accuracy</Text><Text style={styles.factValue}>{accuracy if accuracy else "Unavailable"}</Text>
            <Text style={styles.factLabel}>Elapsed time</Text><Text style={styles.factValue}>{durationText}</Text>
            <Text style={styles.factLabel}>Approximate distance</Text><Text style={styles.factValue}>{str(round(distanceKm, 2))} km · rough straight-line estimate, not a route</Text>
            <Text style={styles.factLabel}>Average speed</Text><Text style={styles.factValue}>{speedText}</Text>
            <Text style={styles.factLabel}>Elevation gain</Text><Text style={styles.factValue}>Unavailable · reliable altitude not supplied</Text>
            <Text style={styles.factLabel}>Last GPS update</Text><Text style={styles.factValue}>{lastUpdate}</Text>
            <Text style={styles.tiny}>Route points recorded: {str(len(route))}. Current map fallback cannot display route overlays.</Text>
        </View>
        <View style={styles.row}><Pressable style={styles.button} onPress={lambda { startTracking(); }}><Text style={styles.buttonText}>{"Resume" if paused else "Start hike"}</Text></Pressable><Pressable style={styles.outlineButton} onPress={lambda { pauseTracking(); }}><Text style={styles.outlineText}>Pause</Text></Pressable><Pressable style={styles.outlineButton} onPress={lambda { stopTracking(); }}><Text style={styles.outlineText}>Stop</Text></Pressable></View>
        <View style={styles.row}><Pressable style={styles.outlineButton} onPress={lambda { shareLocation(); }}><Text style={styles.outlineText}>Share My Location</Text></Pressable><Pressable style={styles.outlineButton} onPress={lambda { copyCoordinates(); }}><Text style={styles.outlineText}>Copy coordinates</Text></Pressable><Pressable style={styles.outlineButton} onPress={lambda { stopSharing(); }}><Text style={styles.outlineText}>Stop sharing</Text></Pressable></View>
        <Text style={styles.tiny}>Session data is temporary and local only. No backend, persistent session store, or live sharing service is configured.</Text>
    </View>;
}
