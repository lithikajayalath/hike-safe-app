import from "@jac/mobui" { View, Text, Pressable }
import from .theme { buildStyles, LIGHT }
glob styles = buildStyles(LIGHT);

def:pub WeatherShortcut(onOpen: Callable[[], None]) -> JsxElement {
    return <Pressable style={styles.weather} onPress={onOpen}>
        <Text style={styles.weatherIcon}>☼</Text>
        <View style={styles.weatherInfo}>
            <Text style={styles.weatherTemp}>Hiking weather</Text>
            <Text style={styles.subtitle}>Forecast unavailable · open weather dashboard</Text>
        </View>
    </Pressable>;
}
