import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config/hotel_info.dart';
import '../core/constants/app_colors.dart';

/// HU40 — Integración de mapa con la ubicación del hotel.
///
/// Muestra un mapa embebido de Google Maps dentro de un WebView (no
/// requiere API key) y un botón que abre la **app de Google Maps** (o el
/// navegador) en la ubicación exacta del hotel.
///
/// `webview_flutter` solo está soportado en Android e iOS; en otras
/// plataformas (escritorio/web) se muestra un marcador estático con el
/// mismo botón para no romper la app.
class HotelMapCard extends StatefulWidget {
  const HotelMapCard({super.key});

  @override
  State<HotelMapCard> createState() => _HotelMapCardState();
}

class _HotelMapCardState extends State<HotelMapCard> {
  WebViewController? _controller;

  bool get _webViewSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    if (_webViewSupported) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppColors.creamLight)
        ..loadRequest(Uri.parse(HotelInfo.mapaEmbedUrl));
    }
  }

  Future<void> _abrirEnGoogleMaps() async {
    final uri = Uri.parse(HotelInfo.googleMapsUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir Google Maps.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 200,
            child: _controller != null
                ? WebViewWidget(controller: _controller!)
                : _mapPlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.place_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    HotelInfo.direccion,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _abrirEnGoogleMaps,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Abrir en Google Maps'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapPlaceholder() {
    return Container(
      color: AppColors.creamSoft,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 48, color: AppColors.chocolate),
          SizedBox(height: 8),
          Text(
            'Vista de mapa disponible en móvil',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
