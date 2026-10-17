import from "@jac/mobui" { View, Text, Pressable, TextInput, ScrollView, Image, useWindowDimensions }
import from .theme { LIGHT, buildStyles }

glob styles = buildStyles(LIGHT);
glob destinations: list[dict] = [
    {"id": "ella", "name": "Ella Rock", "district": "Badulla District", "difficulty": "Moderate", "risk": "Moderate risk", "image": "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1000&q=85", "distance": "8 km", "access": "Check local access", "camp": "No camping info"},
    {"id": "knuckles", "name": "Knuckles Range", "district": "Matale District", "difficulty": "Challenging", "risk": "High risk", "image": "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1000&q=85", "distance": "12 km", "access": "Guide recommended", "camp": "Permit may apply"},
    {"id": "pitu", "name": "Pidurutalagala Foothills", "district": "Nuwara Eliya District", "difficulty": "Moderate", "risk": "Check conditions", "image": "https://images.unsplash.com/photo-1472396961693-142e6e269027?auto=format&fit=crop&w=1000&q=85", "distance": "6 km", "access": "Verify before visit", "camp": "No camping info"},
    {"id": "hantana", "name": "Hantana Ridge", "district": "Kandy District", "difficulty": "Easy", "risk": "Check conditions", "image": "https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=1000&q=85", "distance": "5 km", "access": "Verify before visit", "camp": "No camping info"}
];
glob tabNames: list[str] = ["Home", "Explore", "Start Hike", "Saved", "Profile"];
glob tabIcons: list[str] = ["⌂", "⌕", "↗", "♡", "○"];

def DestinationCard(place: dict, saved: bool, onSave: Callable[[str], None]) -> JsxElement {
    return <View style={styles.card}>
        <View style={styles.destImageWrap}><Image source={{"uri": place["image"]}} style={styles.destImage} resizeMode="cover" /></View>
        <View style={styles.spread}><View style={{"flex": 1, "gap": 4}}><Text style={styles.destName}>{place["name"]}</Text><Text style={styles.destMeta}>{place["district"]} · {place["distance"]}</Text></View><Pressable style={styles.outlineButton} onPress={lambda { onSave(place["id"]); }}><Text style={styles.outlineText}>{"Saved" if saved else "Save"}</Text></Pressable></View>
        <View style={styles.chipRow}><View style={styles.chip}><Text style={styles.chipText}>{place["difficulty"]}</Text></View><View style={styles.riskChip}><Text style={styles.riskText}>{place["risk"]}</Text></View></View>
        <Text style={styles.tiny}>{place["access"]} · {place["camp"]}</Text>
    </View>;
}

def:pub app -> JsxElement {
    has activeTab: str = "Home", query: str = "", savedIds: list[str] = [], selectedFilter: str = "All trails";
    viewport = useWindowDimensions();
    filtered = [p for p in destinations if (not query or query.lower() in p["name"].lower() or query.lower() in p["district"].lower()) and (selectedFilter == "All trails" or selectedFilter == p["difficulty"])];
    savedPlaces = [p for p in destinations if p["id"] in savedIds];

    def toggleSaved(id: str) { if id in savedIds { savedIds = [v for v in savedIds if v != id]; } else { savedIds = savedIds + [id]; } }
    def selectTab(tab: str) { activeTab = tab; query = ""; }

    def topHeader() -> JsxElement {
        return <View style={styles.header}><View style={styles.brandline}><View style={styles.brandMark}><Text style={styles.brandGlyph}>H</Text></View><Text style={styles.brand}>HikeSafe</Text></View><View style={styles.locationIcon}><Text style={styles.locationPin}>⌖</Text></View></View>;
    }
    def searchBox() -> JsxElement {
        return <View style={styles.search}><Text style={styles.searchGlyph}>⌕</Text><TextInput style={styles.searchInput} value={query} placeholder="Search mountains and trails" placeholderTextColor={LIGHT["muted"]} onChangeText={lambda (t: str) { query = t; }} /></View>;
    }
    def sectionHeading(title: str, caption: str) -> JsxElement {
        return <View style={{"gap": 4}}><Text style={styles.sectionTitle}>{title}</Text><Text style={styles.tiny}>{caption}</Text></View>;
    }
    def sampleNotice() -> JsxElement {
        return <View style={styles.notice}><Text style={styles.noticeText}>Development samples only. Trail details, access, safety, and conditions are not verified. Confirm locally before setting out.</Text></View>;
    }

    return <View style={[styles.screen, {"height": viewport.height}]}>
        <ScrollView style={styles.screen} contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={False}>
            {if activeTab == "Home" {
                <View style={{"gap": 22}}>
                    {topHeader()}
                    <View style={{"gap": 7}}><Text style={styles.eyebrow}>YOUR NEXT OUTDOOR DAY</Text><Text style={styles.title}>Find your trail.</Text><Text style={styles.subtitle}>A little closer to the wild, one step at a time.</Text></View>
                    <View style={[styles.card, {"padding": 13}]}><View style={styles.row}><View style={styles.locationIcon}><Text style={styles.locationPin}>⌖</Text></View><View style={{"flex": 1, "gap": 3}}><Text style={styles.tiny}>CURRENT LOCATION</Text><Text style={styles.body}>Kandy, Sri Lanka</Text></View><Text style={styles.chipText}>Change</Text></View></View>
                    {searchBox()}
                    <Pressable style={styles.hero} onPress={lambda { selectTab("Explore"); }}><Image source={{"uri": "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=85"}} style={styles.heroImage} resizeMode="cover"/><View style={styles.heroShade}/><View style={styles.heroContent}><Text style={styles.heroTitle}>Take the scenic route.</Text><Text style={styles.heroSub}>Explore Sri Lanka's highland trails</Text></View></Pressable>
                    {sectionHeading("Nearby trails", "A few ideas around the highlands")}
                    {for p in destinations[:2] { <DestinationCard key={p["id"]} place={p} saved={p["id"] in savedIds} onSave={toggleSaved}/> }}
                    <View style={styles.weather}><Text style={styles.weatherIcon}>☼</Text><View style={styles.weatherInfo}><Text style={styles.weatherTemp}>Weather snapshot</Text><Text style={styles.subtitle}>Local forecast integration coming later</Text></View><Text style={styles.tiny}>PLACEHOLDER</Text></View>
                    {sectionHeading("Saved for later", "Keep a trail in mind")}
                    {if len(savedPlaces) > 0 { for p in savedPlaces { <DestinationCard key={p["id"]} place={p} saved={True} onSave={toggleSaved}/> } } else { <View style={[styles.card, {"alignItems": "center"}]}><Text style={styles.subtitle}>Your saved destinations will appear here.</Text><Pressable style={styles.outlineButton} onPress={lambda { selectTab("Explore"); }}><Text style={styles.outlineText}>Explore trails</Text></Pressable></View> }}
                    <Pressable style={styles.button} onPress={lambda { selectTab("Start Hike"); }}><Text style={styles.buttonText}>Start planning a hike</Text><Text style={styles.buttonText}>→</Text></Pressable>
                    {sampleNotice()}
                </View>;
            }
            elif activeTab == "Explore" {
                <View style={{"gap": 20}}>
                    {topHeader()}<View style={{"gap": 7}}><Text style={styles.eyebrow}>DISCOVER SRI LANKA</Text><Text style={styles.title}>Explore trails</Text><Text style={styles.subtitle}>Find a route that fits your day outdoors.</Text></View>
                    {searchBox()}
                    <ScrollView horizontal={True} showsHorizontalScrollIndicator={False} contentContainerStyle={styles.filterScroll}>
                        <Pressable style={styles.outlineButton} onPress={lambda { selectedFilter = "All trails"; }}><Text style={styles.outlineText}>All trails</Text></Pressable>
                        <Pressable style={styles.outlineButton} onPress={lambda { selectedFilter = "Easy"; }}><Text style={styles.outlineText}>Easy</Text></Pressable>
                        <Pressable style={styles.outlineButton} onPress={lambda { selectedFilter = "Moderate"; }}><Text style={styles.outlineText}>Moderate</Text></Pressable>
                        <Pressable style={styles.outlineButton} onPress={lambda { selectedFilter = "Challenging"; }}><Text style={styles.outlineText}>Challenging</Text></Pressable>
                    </ScrollView>
                    <View style={styles.map}><View style={styles.mapLines}/><View style={styles.mapInner}/><View style={styles.mapPin}><Text style={styles.mapPinText}>⌖</Text></View><Text style={styles.mapLabel}>MAP PREVIEW · LOCATION DATA NOT CONNECTED</Text></View>
                    {sectionHeading("Trail collection", str(len(filtered)) + " sample destinations")}
                    {if len(filtered) == 0 { <View style={styles.emptyState}><Text style={styles.sectionTitle}>No trails found</Text><Text style={styles.subtitle}>Try another search or filter.</Text></View> } else { for p in filtered { <DestinationCard key={p["id"]} place={p} saved={p["id"] in savedIds} onSave={toggleSaved}/> } }}
                    <View style={styles.card}><Text style={styles.sectionTitle}>More filters</Text><View style={styles.chipRow}><View style={styles.chip}><Text style={styles.chipText}>Distance</Text></View><View style={styles.chip}><Text style={styles.chipText}>Risk level</Text></View><View style={styles.chip}><Text style={styles.chipText}>Legal access</Text></View><View style={styles.chip}><Text style={styles.chipText}>Camping</Text></View></View><Text style={styles.tiny}>Informational placeholders; confirm access and camping rules locally.</Text></View>
                    {sampleNotice()}
                </View>;
            }
            elif activeTab == "Start Hike" {
                <View style={{"gap": 22}}>{topHeader()}<View style={{"gap": 7}}><Text style={styles.eyebrow}>BEFORE YOU GO</Text><Text style={styles.title}>Plan a safe hike.</Text><Text style={styles.subtitle}>A simple starting point for a thoughtful day outside.</Text></View><View style={styles.hero}><Image source={{"uri": "https://images.unsplash.com/photo-1472396961693-142e6e269027?auto=format&fit=crop&w=1000&q=85"}} style={styles.heroImage} resizeMode="cover"/><View style={styles.heroShade}/><View style={styles.heroContent}><Text style={styles.heroTitle}>Choose your destination</Text><Text style={styles.heroSub}>Start with a route that suits your group.</Text></View></View><View style={styles.card}><Text style={styles.sectionTitle}>A few good checks</Text><Text style={styles.body}>01  Check current access and weather locally.</Text><View style={styles.separator}/><Text style={styles.body}>02  Tell someone your route and expected return.</Text><View style={styles.separator}/><Text style={styles.body}>03  Carry water, suitable footwear, and a charged phone.</Text></View><Pressable style={styles.button} onPress={lambda { selectTab("Explore"); }}><Text style={styles.buttonText}>Choose a trail</Text></Pressable>{sampleNotice()}</View>;
            }
            elif activeTab == "Saved" {
                <View style={{"gap": 22}}>{topHeader()}<View style={{"gap": 7}}><Text style={styles.eyebrow}>YOUR SHORTLIST</Text><Text style={styles.title}>Saved trails</Text><Text style={styles.subtitle}>Destinations you may want to explore.</Text></View>{if len(savedPlaces) == 0 { <View style={[styles.card, styles.emptyState]}><Text style={styles.sectionTitle}>No saved trails yet</Text><Text style={styles.subtitle}>Save a destination from Home or Explore to find it here.</Text><Pressable style={styles.button} onPress={lambda { selectTab("Explore"); }}><Text style={styles.buttonText}>Explore destinations</Text></Pressable></View> } else { for p in savedPlaces { <DestinationCard key={p["id"]} place={p} saved={True} onSave={toggleSaved}/> } }}{sampleNotice()}</View>;
            }
            else {
                <View style={{"gap": 22}}>{topHeader()}<View style={{"gap": 7}}><Text style={styles.eyebrow}>YOUR OUTDOOR SPACE</Text><Text style={styles.title}>Profile</Text><Text style={styles.subtitle}>A simple home for your hiking preferences.</Text></View><View style={[styles.card, {"alignItems": "center", "paddingVertical": 26}]}><View style={styles.profileCircle}><Text style={styles.profileInitial}>H</Text></View><Text style={styles.sectionTitle}>Hiker profile</Text><Text style={styles.subtitle}>Personal details and preferences will live here.</Text></View><View style={styles.card}><Text style={styles.sectionTitle}>About HikeSafe</Text><Text style={styles.body}>A hiking companion in progress, beginning with Sri Lanka.</Text><View style={styles.separator}/><Text style={styles.tiny}>Trail examples are development samples, not verified recommendations.</Text></View>{sampleNotice()}</View>;
            }}
        </ScrollView>
        <View style={styles.tabs}>{for (i, tab) in enumerate(tabNames) { <Pressable key={tab} style={styles.tab} onPress={lambda { selectTab(tab); }}><Text style={styles.tabIcon}>{tabIcons[i]}</Text><Text style={styles.tabActive if activeTab == tab else styles.tabInactive}>{tab}</Text></Pressable> }}</View>
    </View>;
}
