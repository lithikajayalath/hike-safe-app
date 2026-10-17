import from "@jac/mobui" { View, Text, Pressable, Platform }
import from .theme { buildStyles, LIGHT }
glob styles = buildStyles(LIGHT);

def:pub ExploreMap(onMyLocation: Callable[[str, str], None]) -> JsxElement {
    has locationMessage: str = "Map tile provider is not configured. Destination pins are hidden because coordinates are unverified.";
    def requestLocation {
        if Platform.OS == "web" {
            if navigator and navigator.geolocation {
                geo: any = navigator.geolocation;
                successHandler = onMyLocation;
                geo.getCurrentPosition(
                    lambda (position: any) {
                        successHandler.call(None, str(position.coords.latitude), str(position.coords.longitude));
                    },
                    lambda (_error: any) { locationMessage = "Location permission denied or GPS unavailable. You can continue browsing without GPS."; },
                    {"enableHighAccuracy": True, "timeout": 10000, "maximumAge": 0}
                );
                locationMessage = "Waiting for browser permission. Denied/unavailable location leaves browsing available.";
            } else {
                locationMessage = "Geolocation is unavailable in this browser. Browse the destination list without GPS.";
            }
        } else {
            locationMessage = "Device location is not supported by this map build. Browse the destination list without GPS.";
        }
    }
    return <View style={styles.card}>
        <View style={styles.spread}><Text style={styles.sectionTitle}>Sri Lanka map</Text><Text style={styles.chipText}>Map preview</Text></View>
        <View style={[styles.map, {"height": 210}]}>
            <View style={styles.mapLines}/><View style={styles.mapInner}/>
            <Text style={styles.mapPinText}>Map layer unavailable</Text>
            <Text style={styles.mapLabel}>No configured tile source · no destination coordinates verified</Text>
        </View>
        <View style={styles.row}>
            <Pressable style={styles.outlineButton} onPress={lambda { locationMessage = "Map pan controls are unavailable until a tile provider is configured."; }}><Text style={styles.outlineText}>Pan</Text></Pressable>
            <Pressable style={styles.outlineButton} onPress={lambda { locationMessage = "Map zoom controls are unavailable until a tile provider is configured."; }}><Text style={styles.outlineText}>Zoom</Text></Pressable>
            <Pressable style={styles.button} onPress={lambda { requestLocation(); }}><Text style={styles.buttonText}>My Location</Text></Pressable>
        </View>
        <Text style={styles.tiny}>{locationMessage}</Text>
        <Text style={styles.tiny}>Map tiles and attribution are omitted until an approved tile service is configured. GPS accuracy and distances are not simulated.</Text>
    </View>;
}
