import from "@jac/mobui" { View, Text, Pressable }
import from .theme { buildStyles, LIGHT }
glob styles = buildStyles(LIGHT);

def:pub WeatherDashboard(onBack: Callable[[], None]) -> JsxElement {
    return <View style={{"gap": 16}}>
        <Pressable style={styles.backButton} onPress={onBack}><Text style={styles.outlineText}>‹  Back</Text></Pressable>
        <Text style={styles.eyebrow}>SRI LANKA WEATHER</Text>
        <Text style={styles.title}>Hiking weather</Text>
        <Text style={styles.subtitle}>Live forecasts require verified coordinates for a selected destination.</Text>
        <View style={styles.notice}><Text style={styles.noticeText}>Open-Meteo can provide forecasts without an API key, but destination coordinates are not verified yet. No weather request has been made and no live weather is displayed.</Text></View>
        <View style={styles.card}>
            <Text style={styles.sectionTitle}>Current conditions</Text>
            <Text style={styles.factValue}>Unavailable · no location permission granted</Text>
            <Text style={styles.factLabel}>Temperature · feels like · precipitation</Text><Text style={styles.factValue}>Unavailable</Text>
            <Text style={styles.factLabel}>Wind · humidity · cloud cover · visibility</Text><Text style={styles.factValue}>Unavailable</Text>
            <Text style={styles.factLabel}>Warnings · sunrise · sunset · updated</Text><Text style={styles.factValue}>No forecast retrieved</Text>
        </View>
        <View style={styles.card}>
            <Text style={styles.sectionTitle}>Sri Lanka destinations</Text>
            <Text style={styles.subtitle}>Forecast by mountain requires that destination's coordinates.</Text>
            <Text style={styles.body}>Ella Rock · Badulla District · forecast unavailable; coordinates not verified</Text>
            <Text style={styles.body}>Knuckles Range · Matale District · forecast unavailable; coordinates not verified</Text>
            <Text style={styles.body}>Pidurutalagala Foothills · Nuwara Eliya District · forecast unavailable; coordinates not verified</Text>
            <Text style={styles.body}>Hantana Ridge · Kandy District · forecast unavailable; coordinates not verified</Text>
        </View>
        <View style={styles.card}>
            <Text style={styles.sectionTitle}>Forecast outlook</Text>
            <Text style={styles.factValue}>Hourly next 24 hours: unavailable</Text>
            <Text style={styles.factValue}>Daily outlook: unavailable</Text>
            <Text style={styles.tiny}>Elevation adjustment is not configured. Weather alone cannot determine whether a hike is safe.</Text>
            <Text style={styles.riskUnknownText}>Insufficient weather data</Text>
        </View>
    </View>;
}
