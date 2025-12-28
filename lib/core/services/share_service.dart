import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../data/models/build.dart';
import '../../data/models/component.dart';

/// Service for sharing builds and components
class ShareService {
  final Logger _logger = Logger();

  /// Generate a shareable build link
  /// This creates a deep link or web link to view the build
  String generateBuildLink(Build build) {
    try {
      // In a real app, this would be your actual app's domain
      final baseUrl = 'https://rigcheck.app';
      final buildId = build.uuid ?? build.id?.toString() ?? 'unknown';

      final link = '$baseUrl/builds/$buildId';
      _logger.d('Generated build link: $link');

      return link;
    } catch (e) {
      _logger.e('Failed to generate build link: $e');
      return '';
    }
  }

  /// Generate build summary text for sharing
  String generateBuildSummary(Build build) {
    try {
      final buffer = StringBuffer();
      final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0);

      // Header
      buffer.writeln('=== ${build.name} ===');
      buffer.writeln();

      // Description
      if (build.description != null && build.description!.isNotEmpty) {
        buffer.writeln(build.description);
        buffer.writeln();
      }

      // Use case
      if (build.useCase != null && build.useCase!.isNotEmpty) {
        buffer.writeln('Use Case: ${build.useCase}');
        buffer.writeln();
      }

      // Components
      buffer.writeln('Components:');
      buffer.writeln('-------------');

      if (build.components.isEmpty) {
        buffer.writeln('No components added yet');
      } else {
        final categories = {
          'cpu': 'CPU',
          'cpu-cooler': 'CPU Cooler',
          'motherboard': 'Motherboard',
          'memory': 'Memory',
          'storage': 'Storage',
          'video-card': 'Graphics Card',
          'case': 'Case',
          'power-supply': 'Power Supply',
        };

        for (var entry in build.components.entries) {
          final categoryLabel = categories[entry.key] ?? entry.key;
          final component = entry.value;

          buffer.write('$categoryLabel: ${component.brand} ${component.name}');

          if (component.priceBdt != null) {
            buffer.write(' - ${currencyFormat.format(component.priceBdt)}');
          }

          buffer.writeln();
        }
      }

      buffer.writeln();

      // Summary
      buffer.writeln('Summary:');
      buffer.writeln('-------------');
      buffer.writeln('Total Components: ${build.componentCount}');
      buffer.writeln('Total Cost: ${currencyFormat.format(build.totalCost)}');

      if (build.totalTdp != null && build.totalTdp! > 0) {
        buffer.writeln('Total TDP: ${build.totalTdp}W');
        buffer.writeln('Recommended PSU: ${build.recommendedPsuWattage}W');
      }

      buffer.writeln('Compatibility: ${build.compatibilityStatus}');

      // Footer
      buffer.writeln();
      buffer.writeln('Built with RigCheck - PC Builder App');

      final link = generateBuildLink(build);
      if (link.isNotEmpty) {
        buffer.writeln('View online: $link');
      }

      final summary = buffer.toString();
      _logger.d('Generated build summary (${summary.length} chars)');

      return summary;
    } catch (e) {
      _logger.e('Failed to generate build summary: $e');
      return 'Failed to generate build summary';
    }
  }

  /// Share build as text
  Future<bool> shareBuildAsText(Build build) async {
    try {
      final summary = generateBuildSummary(build);
      final result = await Share.share(
        summary,
        subject: 'Check out my PC build: ${build.name}',
      );

      _logger.d('Share result: ${result.status}');
      return result.status == ShareResultStatus.success;
    } catch (e) {
      _logger.e('Failed to share build: $e');
      return false;
    }
  }

  /// Share build link
  Future<bool> shareBuildLink(Build build) async {
    try {
      final link = generateBuildLink(build);
      if (link.isEmpty) {
        _logger.w('Failed to generate build link');
        return false;
      }

      final message = 'Check out my PC build: ${build.name}\n\n$link';
      final result = await Share.share(
        message,
        subject: build.name,
      );

      _logger.d('Share link result: ${result.status}');
      return result.status == ShareResultStatus.success;
    } catch (e) {
      _logger.e('Failed to share build link: $e');
      return false;
    }
  }

  /// Share build with detailed specs
  Future<bool> shareBuildDetailed(Build build) async {
    try {
      final summary = generateBuildSummary(build);
      final link = generateBuildLink(build);

      final message = link.isNotEmpty
          ? '$summary\n\nView online: $link'
          : summary;

      final result = await Share.share(
        message,
        subject: 'PC Build: ${build.name}',
      );

      _logger.d('Share detailed result: ${result.status}');
      return result.status == ShareResultStatus.success;
    } catch (e) {
      _logger.e('Failed to share build detailed: $e');
      return false;
    }
  }

  /// Generate component summary text
  String generateComponentSummary(Component component) {
    try {
      final buffer = StringBuffer();
      final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0);

      // Header
      buffer.writeln('${component.brand} ${component.name}');
      buffer.writeln();

      // Category
      buffer.writeln('Category: ${component.category}');

      // Price
      if (component.priceBdt != null) {
        buffer.writeln('Price: ${currencyFormat.format(component.priceBdt)}');
      }

      // Availability
      if (component.availabilityStatus != null) {
        buffer.writeln('Availability: ${component.availabilityStatus}');
      }

      // Specs
      if (component.specs != null && component.specs!.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('Specifications:');
        buffer.writeln('-------------');

        component.specs!.forEach((key, value) {
          final formattedKey = key.replaceAll('_', ' ').toUpperCase();
          buffer.writeln('$formattedKey: $value');
        });
      }

      // Footer
      buffer.writeln();
      buffer.writeln('Found on RigCheck - PC Builder App');

      final summary = buffer.toString();
      _logger.d('Generated component summary (${summary.length} chars)');

      return summary;
    } catch (e) {
      _logger.e('Failed to generate component summary: $e');
      return 'Failed to generate component summary';
    }
  }

  /// Share component as text
  Future<bool> shareComponent(Component component) async {
    try {
      final summary = generateComponentSummary(component);
      final result = await Share.share(
        summary,
        subject: '${component.brand} ${component.name}',
      );

      _logger.d('Share component result: ${result.status}');
      return result.status == ShareResultStatus.success;
    } catch (e) {
      _logger.e('Failed to share component: $e');
      return false;
    }
  }

  /// Copy text to clipboard
  Future<bool> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      _logger.d('Copied to clipboard (${text.length} chars)');
      return true;
    } catch (e) {
      _logger.e('Failed to copy to clipboard: $e');
      return false;
    }
  }

  /// Copy build summary to clipboard
  Future<bool> copyBuildSummary(Build build) async {
    try {
      final summary = generateBuildSummary(build);
      return await copyToClipboard(summary);
    } catch (e) {
      _logger.e('Failed to copy build summary: $e');
      return false;
    }
  }

  /// Copy build link to clipboard
  Future<bool> copyBuildLink(Build build) async {
    try {
      final link = generateBuildLink(build);
      if (link.isEmpty) {
        _logger.w('Failed to generate build link');
        return false;
      }

      return await copyToClipboard(link);
    } catch (e) {
      _logger.e('Failed to copy build link: $e');
      return false;
    }
  }

  /// Copy component summary to clipboard
  Future<bool> copyComponentSummary(Component component) async {
    try {
      final summary = generateComponentSummary(component);
      return await copyToClipboard(summary);
    } catch (e) {
      _logger.e('Failed to copy component summary: $e');
      return false;
    }
  }

  /// Generate export text for build (formatted for file export)
  String generateBuildExportText(Build build) {
    try {
      final buffer = StringBuffer();
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
      final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0);

      // Header with timestamp
      buffer.writeln('PC BUILD EXPORT');
      buffer.writeln('Generated: ${dateFormat.format(DateTime.now())}');
      buffer.writeln('=' * 50);
      buffer.writeln();

      // Build information
      buffer.writeln('BUILD: ${build.name}');
      buffer.writeln();

      if (build.description != null && build.description!.isNotEmpty) {
        buffer.writeln('DESCRIPTION:');
        buffer.writeln(build.description);
        buffer.writeln();
      }

      if (build.useCase != null && build.useCase!.isNotEmpty) {
        buffer.writeln('USE CASE: ${build.useCase}');
        buffer.writeln();
      }

      // Components list
      buffer.writeln('COMPONENTS:');
      buffer.writeln('-' * 50);

      if (build.components.isEmpty) {
        buffer.writeln('No components added');
      } else {
        final categories = {
          'cpu': 'CPU',
          'cpu-cooler': 'CPU Cooler',
          'motherboard': 'Motherboard',
          'memory': 'Memory',
          'storage': 'Storage',
          'video-card': 'Graphics Card',
          'case': 'Case',
          'power-supply': 'Power Supply',
        };

        for (var entry in build.components.entries) {
          final categoryLabel = categories[entry.key] ?? entry.key;
          final component = entry.value;

          buffer.writeln();
          buffer.writeln('[$categoryLabel]');
          buffer.writeln('  Brand: ${component.brand}');
          buffer.writeln('  Model: ${component.name}');

          if (component.priceBdt != null) {
            buffer.writeln('  Price: ${currencyFormat.format(component.priceBdt)}');
          }

          if (component.availabilityStatus != null) {
            buffer.writeln('  Availability: ${component.availabilityStatus}');
          }

          // Key specs
          if (component.specs != null && component.specs!.isNotEmpty) {
            buffer.writeln('  Specs:');
            component.specs!.forEach((key, value) {
              final formattedKey = key.replaceAll('_', ' ');
              buffer.writeln('    - $formattedKey: $value');
            });
          }
        }
      }

      buffer.writeln();
      buffer.writeln('-' * 50);

      // Summary
      buffer.writeln();
      buffer.writeln('SUMMARY:');
      buffer.writeln('  Total Components: ${build.componentCount}');
      buffer.writeln('  Total Cost: ${currencyFormat.format(build.totalCost)}');

      if (build.totalTdp != null && build.totalTdp! > 0) {
        buffer.writeln('  Total TDP: ${build.totalTdp}W');
        buffer.writeln('  Recommended PSU: ${build.recommendedPsuWattage}W');
      }

      buffer.writeln('  Compatibility: ${build.compatibilityStatus}');
      buffer.writeln('  Visibility: ${build.visibility}');
      buffer.writeln('  Created: ${dateFormat.format(build.createdAt)}');
      buffer.writeln('  Updated: ${dateFormat.format(build.updatedAt)}');

      // Footer
      buffer.writeln();
      buffer.writeln('=' * 50);
      buffer.writeln('Exported from RigCheck - PC Builder App');

      final link = generateBuildLink(build);
      if (link.isNotEmpty) {
        buffer.writeln('View online: $link');
      }

      return buffer.toString();
    } catch (e) {
      _logger.e('Failed to generate build export text: $e');
      return 'Failed to generate export';
    }
  }

  /// Share build export (detailed version for export)
  Future<bool> shareBuildExport(Build build) async {
    try {
      final exportText = generateBuildExportText(build);
      final result = await Share.share(
        exportText,
        subject: 'PC Build Export: ${build.name}',
      );

      _logger.d('Share export result: ${result.status}');
      return result.status == ShareResultStatus.success;
    } catch (e) {
      _logger.e('Failed to share build export: $e');
      return false;
    }
  }
}
