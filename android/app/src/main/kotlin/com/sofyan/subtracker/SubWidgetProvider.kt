package com.sofyan.subtracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class SubWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val title = widgetData.getString("title", "Tagihan Terdekat")
                val subName = widgetData.getString("sub_name", "-")
                val subPrice = widgetData.getString("sub_price", "")
                val subDue = widgetData.getString("sub_due", "")

                setTextViewText(R.id.tv_title, title)
                setTextViewText(R.id.tv_sub_name, subName)
                setTextViewText(R.id.tv_sub_price, subPrice)
                setTextViewText(R.id.tv_sub_due, subDue)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
