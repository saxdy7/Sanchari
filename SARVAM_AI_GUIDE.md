# Sarvam AI Integration Guide

## 🎯 Overview
Sarvam AI is now integrated into Sanchari for intelligent trip planning using India's sovereign AI platform.

## ✅ What's Integrated

### 1. **Sarvam AI Service** (`lib/services/sarvam_ai_service.dart`)
Core service with methods:
- `chat()` - General AI conversations
- `getPlaceDescription()` - AI-powered place descriptions
- `getTripRecommendations()` - Personalized itinerary suggestions
- `getLocalInsights()` - Hidden gems and local favorites
- `enhanceTripWithAI()` - Enhance existing trips with AI
- `getSeasonalAdvice()` - Weather and seasonal tips

### 2. **Providers** (`lib/services/sarvam_ai_provider.dart`)
Riverpod providers for reactive AI data:
- `sarvamAIServiceProvider` - Service instance
- `placeDescriptionProvider` - Place-specific descriptions
- `tripRecommendationsProvider` - Trip suggestions
- `localInsightsProvider` - Local tips and hidden gems
- `enhancedTripProvider` - Enhanced trip planning
- `seasonalAdviceProvider` - Seasonal travel advice

### 3. **UI Widgets** (`lib/features/trips/widgets/ai_insights_card.dart`)
Ready-to-use widgets:
- `AIInsightsCard` - Full trip recommendations card
- `PlaceAIDescription` - Compact place description widget

### 4. **Demo Screen** (`lib/features/trips/sarvam_ai_demo_screen.dart`)
Complete example showing all features in action.

---

## 🚀 Quick Start

### Option 1: Use Pre-built Widgets
```dart
import 'package:sanchari/features/trips/widgets/ai_insights_card.dart';

// In your trip planning screen
AIInsightsCard(
  destination: 'Jaipur',
  days: 3,
  interests: ['Heritage', 'Food', 'Shopping'],
)

// For place details
PlaceAIDescription(
  placeName: 'Hawa Mahal',
  city: 'Jaipur',
  state: 'Rajasthan',
)
```

### Option 2: Use Providers Directly
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanchari/services/sarvam_ai_provider.dart';

// In a ConsumerWidget
final recommendations = ref.watch(
  tripRecommendationsProvider({
    'destination': 'Manali',
    'days': 4,
    'interests': ['Adventure', 'Nature'],
  }),
);

recommendations.when(
  data: (text) => Text(text),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

### Option 3: Direct Service Usage
```dart
import 'package:sanchari/services/sarvam_ai_service.dart';

final service = SarvamAIService();

// Get place description
final description = await service.getPlaceDescription(
  placeName: 'Taj Mahal',
  city: 'Agra',
  state: 'Uttar Pradesh',
);

// Custom chat
final response = await service.chat(
  prompt: 'Best street food in Delhi?',
  systemPrompt: 'You are a local Delhi food expert.',
);
```

---

## 🎨 Integration Examples

### 1. Add AI to Trip Result Screen
```dart
// In trip_result_screen.dart
import '../widgets/ai_insights_card.dart';

// Add this widget to your trip results
AIInsightsCard(
  destination: widget.tripData['destination'],
  days: widget.tripData['duration'],
  interests: ['sightseeing', 'food'],
)
```

### 2. Enhance Spot Details
```dart
// When showing spot details
PlaceAIDescription(
  placeName: spot.name,
  city: spot.city,
  state: spot.state,
)
```

### 3. Add Chat Assistant
```dart
// Create a chat button in your app
FloatingActionButton(
  onPressed: () async {
    final service = ref.read(sarvamAIServiceProvider);
    final answer = await service.chat(
      prompt: userQuestion,
      systemPrompt: 'You are a helpful Indian travel guide.',
    );
    // Show answer in dialog
  },
  child: Icon(Icons.chat),
)
```

---

## 🔧 Configuration

### API Key Setup
Already configured in `lib/config/sarvam_config.dart`:
```dart
static const String apiKey = 'sk_d7lugoxa_ymP6eDIIsI2i8dSmPKCdii95';
```

### Customize Models
```dart
// In sarvam_config.dart
static const String defaultModel = 'sarvam-1'; // or 'sarvam-m'
```

### Adjust Timeout
```dart
static const Duration timeout = Duration(seconds: 30);
```

---

## 📱 See It In Action

### View Demo Screen
Add this navigation anywhere in your app:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SarvamAIDemoScreen(),
  ),
);
```

### Or add to your navigation menu:
```dart
// In navigation_screen.dart
ListTile(
  leading: Icon(Icons.psychology),
  title: Text('AI Travel Assistant'),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => SarvamAIDemoScreen()),
  ),
)
```

---

## 💡 Use Cases

### 1. **Trip Planning**
- Generate day-by-day itineraries
- Get personalized recommendations
- Suggest activities based on interests

### 2. **Place Discovery**
- Rich descriptions of tourist spots
- Best times to visit
- Local tips and insider knowledge

### 3. **Travel Advice**
- Weather and seasonal guidance
- What to pack
- Festival and event information

### 4. **Local Insights**
- Hidden gems tourists miss
- Authentic local experiences
- Restaurant and cafe recommendations

### 5. **Interactive Chat**
- Answer travel questions
- Help with bookings and planning
- Provide real-time assistance

---

## 🎯 Best Practices

1. **Error Handling**: Always wrap AI calls in try-catch
2. **Loading States**: Show loading indicators for better UX
3. **Fallbacks**: Provide default content if AI fails
4. **Caching**: Consider caching responses for frequently asked queries
5. **Rate Limiting**: Be mindful of API usage

---

## 📊 Features

✅ **Multi-language Support** - 11 Indian languages  
✅ **Context-Aware** - Understands Indian travel context  
✅ **Real-time** - Fast responses (< 30s)  
✅ **Sovereign AI** - India-first AI platform  
✅ **Comprehensive** - Trip planning, places, food, culture  

---

## 🔗 Resources

- **Sarvam AI Docs**: https://docs.sarvam.ai
- **Dashboard**: https://dashboard.sarvam.ai
- **Discord Community**: https://discord.gg/8ka56wQaT3

---

## 🚦 Next Steps

1. **Run the demo**: Navigate to `SarvamAIDemoScreen`
2. **Test the API**: Try different prompts and see responses
3. **Integrate**: Add AI widgets to your existing screens
4. **Customize**: Modify prompts for your specific needs

---

**Need Help?** Check the demo screen for working examples of all features!
