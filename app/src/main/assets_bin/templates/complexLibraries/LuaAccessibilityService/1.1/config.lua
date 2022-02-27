name="Lua Accessibility Service"
keys={
  am_application_bottom={[[        <service 
            android:enabled="true" 
            android:exported="true" 
            android:label="@string/app_name" 
            android:name="com.androlua.LuaAccessibilityService" 
            android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE">
            <meta-data 
                android:name="android.accessibilityservice" 
                android:resource="@xml/accessibility_service_config" />
            <intent-filter>
                <action 
                    android:name="android.accessibilityservice.AccessibilityService" />
                <category 
                    android:name="android.accessibilityservice.category.FEEDBACK_AUDIBLE" />
                <category 
                    android:name="android.accessibilityservice.category.FEEDBACK_HAPTIC" />
                <category 
                    android:name="android.accessibilityservice.category.FEEDBACK_SPOKEN" />
            </intent-filter>
        </service>]],},
}

support="all"