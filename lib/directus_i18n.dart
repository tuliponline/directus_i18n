library directus_i18n;

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:synchronized/synchronized.dart';

// Core parts
part 'src/config/directus_i18n_config.dart';
part 'src/loader/directus_i18n_loader.dart';
part 'src/repository/directus_i18n_repository.dart';
part 'src/extension/i18n_keys_extension.dart';
part 'src/model/i18n_keys.dart';
part 'src/service/directus_i18n_service.dart';
part 'src/generator/key_generator.dart';

// Dynamic i18n parts
part 'src/service/dynamic_i18n_service.dart';
part 'src/extension/dynamic_i18n_extension.dart';
part 'src/widget/dynamic_i18n_widget.dart';

// Runtime enum generation parts
part 'src/service/runtime_enum_generator.dart';
part 'src/service/auto_enum_service.dart';
part 'src/service/hybrid_i18n_service.dart';

// Error code management parts
part 'src/model/error_code.dart';
part 'src/service/error_code_service.dart';
part 'src/extension/error_code_extension.dart';
part 'src/widget/error_code_widget.dart';

// Combined service parts
part 'src/service/combined_i18n_service.dart';

