import 'package:flutter/material.dart';

IconData getIconForTag(String iconName) {
  switch (iconName) {
    case 'restaurant':
      return Icons.restaurant_menu;
    case 'commute':
      return Icons.commute;
    case 'shopping_bag':
      return Icons.shopping_bag_outlined;
    case 'sports_esports':
      return Icons.sports_esports_outlined;
    case 'house':
      return Icons.house_siding;
    case 'flight':
      return Icons.flight_takeoff;
    case 'movie':
      return Icons.movie_filter;
    case 'receipt':
      return Icons.receipt_long;
    case 'health':
      return Icons.healing;
    case 'label':
      return Icons.label_outline;
    case 'shopping_cart':
      return Icons.shopping_cart_outlined;
    case 'local_cafe':
      return Icons.local_cafe;
    case 'school':
      return Icons.school;
    case 'pets':
      return Icons.pets;
    case 'card_giftcard':
      return Icons.card_giftcard;
    case 'subscriptions':
      return Icons.subscriptions_outlined;
    case 'local_gas_station':
      return Icons.local_gas_station;
    case 'content_cut':
      return Icons.content_cut;
    case 'lightbulb':
      return Icons.lightbulb_outline;
    case 'construction':
      return Icons.construction;  
    case 'savings':
      return Icons.savings_outlined;  
    default:
      return Icons.help_outline;
  }
}