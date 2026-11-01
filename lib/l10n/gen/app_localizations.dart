import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ru')];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Kadra'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get navHome;

  /// No description provided for @navTools.
  ///
  /// In ru, this message translates to:
  /// **'Инструменты'**
  String get navTools;

  /// No description provided for @navDownloads.
  ///
  /// In ru, this message translates to:
  /// **'Загрузки'**
  String get navDownloads;

  /// No description provided for @navQueue.
  ///
  /// In ru, this message translates to:
  /// **'Очередь'**
  String get navQueue;

  /// No description provided for @navPresets.
  ///
  /// In ru, this message translates to:
  /// **'Пресеты'**
  String get navPresets;

  /// No description provided for @navComponents.
  ///
  /// In ru, this message translates to:
  /// **'Компоненты'**
  String get navComponents;

  /// No description provided for @navSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get navSettings;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @copy.
  ///
  /// In ru, this message translates to:
  /// **'Копировать'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get copied;

  /// No description provided for @choose.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать'**
  String get choose;

  /// No description provided for @search.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get search;

  /// No description provided for @more.
  ///
  /// In ru, this message translates to:
  /// **'Ещё'**
  String get more;

  /// No description provided for @auto.
  ///
  /// In ru, this message translates to:
  /// **'авто'**
  String get auto;

  /// No description provided for @notSet.
  ///
  /// In ru, this message translates to:
  /// **'Не задано'**
  String get notSet;

  /// No description provided for @nothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get nothingFound;

  /// No description provided for @helpTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get helpTooltip;

  /// No description provided for @resetTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get resetTooltip;

  /// No description provided for @resetSection.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить раздел'**
  String get resetSection;

  /// No description provided for @resetAll.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить все настройки'**
  String get resetAll;

  /// No description provided for @install.
  ///
  /// In ru, this message translates to:
  /// **'Установить'**
  String get install;

  /// No description provided for @update.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get update;

  /// No description provided for @reinstall.
  ///
  /// In ru, this message translates to:
  /// **'Переустановить'**
  String get reinstall;

  /// No description provided for @rollback.
  ///
  /// In ru, this message translates to:
  /// **'Откатить'**
  String get rollback;

  /// No description provided for @remove.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get remove;

  /// No description provided for @activate.
  ///
  /// In ru, this message translates to:
  /// **'Сделать активной'**
  String get activate;

  /// No description provided for @reload.
  ///
  /// In ru, this message translates to:
  /// **'Перечитать файл'**
  String get reload;

  /// No description provided for @pause.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get resume;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @openFolder.
  ///
  /// In ru, this message translates to:
  /// **'Открыть папку'**
  String get openFolder;

  /// No description provided for @showLog.
  ///
  /// In ru, this message translates to:
  /// **'Показать лог'**
  String get showLog;

  /// No description provided for @showCommand.
  ///
  /// In ru, this message translates to:
  /// **'Показать команду'**
  String get showCommand;

  /// No description provided for @removeFromList.
  ///
  /// In ru, this message translates to:
  /// **'Убрать из списка'**
  String get removeFromList;

  /// No description provided for @logTitle.
  ///
  /// In ru, this message translates to:
  /// **'Полный лог'**
  String get logTitle;

  /// No description provided for @commandTitle.
  ///
  /// In ru, this message translates to:
  /// **'Команда'**
  String get commandTitle;

  /// No description provided for @unitB.
  ///
  /// In ru, this message translates to:
  /// **'Б'**
  String get unitB;

  /// No description provided for @unitKB.
  ///
  /// In ru, this message translates to:
  /// **'КБ'**
  String get unitKB;

  /// No description provided for @unitMB.
  ///
  /// In ru, this message translates to:
  /// **'МБ'**
  String get unitMB;

  /// No description provided for @unitGB.
  ///
  /// In ru, this message translates to:
  /// **'ГБ'**
  String get unitGB;

  /// No description provided for @unitTB.
  ///
  /// In ru, this message translates to:
  /// **'ТБ'**
  String get unitTB;

  /// No description provided for @unitKbps.
  ///
  /// In ru, this message translates to:
  /// **'кбит/с'**
  String get unitKbps;

  /// No description provided for @unitMbps.
  ///
  /// In ru, this message translates to:
  /// **'Мбит/с'**
  String get unitMbps;

  /// No description provided for @unitFps.
  ///
  /// In ru, this message translates to:
  /// **'к/с'**
  String get unitFps;

  /// No description provided for @unitHz.
  ///
  /// In ru, this message translates to:
  /// **'Гц'**
  String get unitHz;

  /// No description provided for @unitSecond.
  ///
  /// In ru, this message translates to:
  /// **'с'**
  String get unitSecond;

  /// No description provided for @homeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get homeTitle;

  /// No description provided for @openFile.
  ///
  /// In ru, this message translates to:
  /// **'Открыть файл'**
  String get openFile;

  /// No description provided for @closeFile.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть файл'**
  String get closeFile;

  /// No description provided for @dropTitle.
  ///
  /// In ru, this message translates to:
  /// **'Перетащите файл сюда'**
  String get dropTitle;

  /// No description provided for @dropSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'или нажмите, чтобы выбрать: видео, аудио, картинка'**
  String get dropSubtitle;

  /// No description provided for @shortcutOpenHint.
  ///
  /// In ru, this message translates to:
  /// **'Ctrl+O — открыть файл, Ctrl+1…7 — разделы'**
  String get shortcutOpenHint;

  /// No description provided for @probeFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось прочитать файл'**
  String get probeFailed;

  /// No description provided for @openAnother.
  ///
  /// In ru, this message translates to:
  /// **'Открыть другой'**
  String get openAnother;

  /// No description provided for @quickActions.
  ///
  /// In ru, this message translates to:
  /// **'Быстрые действия'**
  String get quickActions;

  /// No description provided for @ffmpegMissingTitle.
  ///
  /// In ru, this message translates to:
  /// **'ffmpeg не найден'**
  String get ffmpegMissingTitle;

  /// No description provided for @ffmpegMissingBody.
  ///
  /// In ru, this message translates to:
  /// **'Без него приложение не может работать с файлами. Установите ffmpeg в разделе «Компоненты» — это займёт минуту.'**
  String get ffmpegMissingBody;

  /// No description provided for @openComponents.
  ///
  /// In ru, this message translates to:
  /// **'Открыть «Компоненты»'**
  String get openComponents;

  /// No description provided for @addedToQueue.
  ///
  /// In ru, this message translates to:
  /// **'Задача добавлена в очередь'**
  String get addedToQueue;

  /// No description provided for @openQueue.
  ///
  /// In ru, this message translates to:
  /// **'Открыть очередь'**
  String get openQueue;

  /// No description provided for @infoContainer.
  ///
  /// In ru, this message translates to:
  /// **'Контейнер'**
  String get infoContainer;

  /// No description provided for @infoFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат'**
  String get infoFormat;

  /// No description provided for @infoDuration.
  ///
  /// In ru, this message translates to:
  /// **'Длительность'**
  String get infoDuration;

  /// No description provided for @infoSize.
  ///
  /// In ru, this message translates to:
  /// **'Размер'**
  String get infoSize;

  /// No description provided for @infoBitrate.
  ///
  /// In ru, this message translates to:
  /// **'Битрейт'**
  String get infoBitrate;

  /// No description provided for @infoStartTime.
  ///
  /// In ru, this message translates to:
  /// **'Начало'**
  String get infoStartTime;

  /// No description provided for @infoStreams.
  ///
  /// In ru, this message translates to:
  /// **'Потоков'**
  String get infoStreams;

  /// No description provided for @infoChapters.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} глава} few{{count} главы} many{{count} глав} other{{count} главы}}'**
  String infoChapters(int count);

  /// No description provided for @infoTags.
  ///
  /// In ru, this message translates to:
  /// **'Теги'**
  String get infoTags;

  /// No description provided for @infoCodec.
  ///
  /// In ru, this message translates to:
  /// **'Кодек'**
  String get infoCodec;

  /// No description provided for @infoResolution.
  ///
  /// In ru, this message translates to:
  /// **'Разрешение'**
  String get infoResolution;

  /// No description provided for @infoFrameRate.
  ///
  /// In ru, this message translates to:
  /// **'Частота кадров'**
  String get infoFrameRate;

  /// No description provided for @infoPixelFormat.
  ///
  /// In ru, this message translates to:
  /// **'Пиксельный формат'**
  String get infoPixelFormat;

  /// No description provided for @infoBits.
  ///
  /// In ru, this message translates to:
  /// **'{bits} бит'**
  String infoBits(int bits);

  /// No description provided for @infoColor.
  ///
  /// In ru, this message translates to:
  /// **'Цвет'**
  String get infoColor;

  /// No description provided for @infoFieldOrder.
  ///
  /// In ru, this message translates to:
  /// **'Развёртка'**
  String get infoFieldOrder;

  /// No description provided for @infoRotation.
  ///
  /// In ru, this message translates to:
  /// **'Поворот'**
  String get infoRotation;

  /// No description provided for @infoMastering.
  ///
  /// In ru, this message translates to:
  /// **'Мастеринг HDR'**
  String get infoMastering;

  /// No description provided for @infoContentLight.
  ///
  /// In ru, this message translates to:
  /// **'Уровни яркости'**
  String get infoContentLight;

  /// No description provided for @infoSampleRate.
  ///
  /// In ru, this message translates to:
  /// **'Частота дискретизации'**
  String get infoSampleRate;

  /// No description provided for @infoChannels.
  ///
  /// In ru, this message translates to:
  /// **'Каналы'**
  String get infoChannels;

  /// No description provided for @infoSampleFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат сэмплов'**
  String get infoSampleFormat;

  /// No description provided for @infoFrames.
  ///
  /// In ru, this message translates to:
  /// **'Кадров'**
  String get infoFrames;

  /// No description provided for @infoVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get infoVersion;

  /// No description provided for @streamVideo.
  ///
  /// In ru, this message translates to:
  /// **'Видео'**
  String get streamVideo;

  /// No description provided for @streamAudio.
  ///
  /// In ru, this message translates to:
  /// **'Аудио'**
  String get streamAudio;

  /// No description provided for @streamSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Субтитры'**
  String get streamSubtitle;

  /// No description provided for @streamCover.
  ///
  /// In ru, this message translates to:
  /// **'Обложка'**
  String get streamCover;

  /// No description provided for @streamAttachment.
  ///
  /// In ru, this message translates to:
  /// **'Вложение'**
  String get streamAttachment;

  /// No description provided for @streamData.
  ///
  /// In ru, this message translates to:
  /// **'Данные'**
  String get streamData;

  /// No description provided for @dispositionDefault.
  ///
  /// In ru, this message translates to:
  /// **'по умолчанию'**
  String get dispositionDefault;

  /// No description provided for @dispositionForced.
  ///
  /// In ru, this message translates to:
  /// **'принудительные'**
  String get dispositionForced;

  /// No description provided for @toolsSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Найти инструмент: «сжать», «gif», «субтитры»…'**
  String get toolsSearchHint;

  /// No description provided for @toolComingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Появится на этапе {stage} разработки'**
  String toolComingSoon(int stage);

  /// No description provided for @stageLabel.
  ///
  /// In ru, this message translates to:
  /// **'этап {stage}'**
  String stageLabel(int stage);

  /// No description provided for @losslessTag.
  ///
  /// In ru, this message translates to:
  /// **'мгновенно, без потери качества'**
  String get losslessTag;

  /// No description provided for @needsOtherBuild.
  ///
  /// In ru, this message translates to:
  /// **'нужна другая сборка'**
  String get needsOtherBuild;

  /// No description provided for @needsBuildTooltip.
  ///
  /// In ru, this message translates to:
  /// **'В установленной сборке ffmpeg нет: {names}. Установите full-сборку в «Компонентах».'**
  String needsBuildTooltip(String names);

  /// No description provided for @catAnalysis.
  ///
  /// In ru, this message translates to:
  /// **'Анализ и информация'**
  String get catAnalysis;

  /// No description provided for @catConvert.
  ///
  /// In ru, this message translates to:
  /// **'Конвертация и сжатие'**
  String get catConvert;

  /// No description provided for @catEdit.
  ///
  /// In ru, this message translates to:
  /// **'Монтаж и редактирование'**
  String get catEdit;

  /// No description provided for @catAudio.
  ///
  /// In ru, this message translates to:
  /// **'Аудио'**
  String get catAudio;

  /// No description provided for @catSubtitles.
  ///
  /// In ru, this message translates to:
  /// **'Субтитры'**
  String get catSubtitles;

  /// No description provided for @catImages.
  ///
  /// In ru, this message translates to:
  /// **'Изображения и анимация'**
  String get catImages;

  /// No description provided for @catMetadata.
  ///
  /// In ru, this message translates to:
  /// **'Метаданные и главы'**
  String get catMetadata;

  /// No description provided for @catCapture.
  ///
  /// In ru, this message translates to:
  /// **'Запись и стриминг'**
  String get catCapture;

  /// No description provided for @catRepair.
  ///
  /// In ru, this message translates to:
  /// **'Ремонт файлов'**
  String get catRepair;

  /// No description provided for @catDownload.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка видео'**
  String get catDownload;

  /// No description provided for @catAutomation.
  ///
  /// In ru, this message translates to:
  /// **'Пакетная обработка'**
  String get catAutomation;

  /// No description provided for @catExpert.
  ///
  /// In ru, this message translates to:
  /// **'Режим эксперта'**
  String get catExpert;

  /// No description provided for @toolMediaInfo.
  ///
  /// In ru, this message translates to:
  /// **'Информация о файле'**
  String get toolMediaInfo;

  /// No description provided for @toolMediaInfoDesc.
  ///
  /// In ru, this message translates to:
  /// **'Контейнер, потоки, кодеки, битрейт, HDR, главы и теги.'**
  String get toolMediaInfoDesc;

  /// No description provided for @toolIntegrity.
  ///
  /// In ru, this message translates to:
  /// **'Проверка целостности'**
  String get toolIntegrity;

  /// No description provided for @toolIntegrityDesc.
  ///
  /// In ru, this message translates to:
  /// **'Декодирует файл целиком и перечисляет все найденные ошибки.'**
  String get toolIntegrityDesc;

  /// No description provided for @toolLoudness.
  ///
  /// In ru, this message translates to:
  /// **'Замер громкости'**
  String get toolLoudness;

  /// No description provided for @toolLoudnessDesc.
  ///
  /// In ru, this message translates to:
  /// **'LUFS, True Peak и LRA по стандарту EBU R128.'**
  String get toolLoudnessDesc;

  /// No description provided for @toolWaveform.
  ///
  /// In ru, this message translates to:
  /// **'Осциллограмма и спектр'**
  String get toolWaveform;

  /// No description provided for @toolWaveformDesc.
  ///
  /// In ru, this message translates to:
  /// **'Картинка с формой волны или спектрограммой звука.'**
  String get toolWaveformDesc;

  /// No description provided for @toolDetect.
  ///
  /// In ru, this message translates to:
  /// **'Детекторы'**
  String get toolDetect;

  /// No description provided for @toolDetectDesc.
  ///
  /// In ru, this message translates to:
  /// **'Тишина, чёрные и замершие кадры, смена сцен, чёрные поля.'**
  String get toolDetectDesc;

  /// No description provided for @toolCompareQuality.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение качества'**
  String get toolCompareQuality;

  /// No description provided for @toolCompareQualityDesc.
  ///
  /// In ru, this message translates to:
  /// **'VMAF, PSNR и SSIM между оригиналом и результатом.'**
  String get toolCompareQualityDesc;

  /// No description provided for @toolConvert.
  ///
  /// In ru, this message translates to:
  /// **'Конвертация'**
  String get toolConvert;

  /// No description provided for @toolConvertDesc.
  ///
  /// In ru, this message translates to:
  /// **'Любой контейнер и кодек: MP4, MKV, WebM, MP3, FLAC и другие.'**
  String get toolConvertDesc;

  /// No description provided for @toolCompress.
  ///
  /// In ru, this message translates to:
  /// **'Сжатие'**
  String get toolCompress;

  /// No description provided for @toolCompressDesc.
  ///
  /// In ru, this message translates to:
  /// **'Уменьшить размер: по качеству или до заданного размера файла.'**
  String get toolCompressDesc;

  /// No description provided for @toolHdrToSdr.
  ///
  /// In ru, this message translates to:
  /// **'HDR → SDR'**
  String get toolHdrToSdr;

  /// No description provided for @toolHdrToSdrDesc.
  ///
  /// In ru, this message translates to:
  /// **'Тонмаппинг HDR-видео для обычных экранов.'**
  String get toolHdrToSdrDesc;

  /// No description provided for @toolTrim.
  ///
  /// In ru, this message translates to:
  /// **'Обрезка'**
  String get toolTrim;

  /// No description provided for @toolTrimDesc.
  ///
  /// In ru, this message translates to:
  /// **'Быстро по ключевым кадрам или точно до кадра.'**
  String get toolTrimDesc;

  /// No description provided for @toolCutJoin.
  ///
  /// In ru, this message translates to:
  /// **'Вырезать фрагменты'**
  String get toolCutJoin;

  /// No description provided for @toolCutJoinDesc.
  ///
  /// In ru, this message translates to:
  /// **'Удалить лишние куски или оставить только нужные.'**
  String get toolCutJoinDesc;

  /// No description provided for @toolConcat.
  ///
  /// In ru, this message translates to:
  /// **'Склейка'**
  String get toolConcat;

  /// No description provided for @toolConcatDesc.
  ///
  /// In ru, this message translates to:
  /// **'Соединить несколько файлов в один.'**
  String get toolConcatDesc;

  /// No description provided for @toolSplit.
  ///
  /// In ru, this message translates to:
  /// **'Разделение'**
  String get toolSplit;

  /// No description provided for @toolSplitDesc.
  ///
  /// In ru, this message translates to:
  /// **'По времени, размеру, главам, тишине или сценам.'**
  String get toolSplitDesc;

  /// No description provided for @toolCropScale.
  ///
  /// In ru, this message translates to:
  /// **'Кадр и размер'**
  String get toolCropScale;

  /// No description provided for @toolCropScaleDesc.
  ///
  /// In ru, this message translates to:
  /// **'Кадрирование, масштаб, поворот, вертикальное видео.'**
  String get toolCropScaleDesc;

  /// No description provided for @toolSpeed.
  ///
  /// In ru, this message translates to:
  /// **'Скорость и FPS'**
  String get toolSpeed;

  /// No description provided for @toolSpeedDesc.
  ///
  /// In ru, this message translates to:
  /// **'Ускорение, замедление, реверс, интерполяция кадров.'**
  String get toolSpeedDesc;

  /// No description provided for @toolRestore.
  ///
  /// In ru, this message translates to:
  /// **'Улучшение видео'**
  String get toolRestore;

  /// No description provided for @toolRestoreDesc.
  ///
  /// In ru, this message translates to:
  /// **'Деинтерлейс, стабилизация, шумоподавление, резкость.'**
  String get toolRestoreDesc;

  /// No description provided for @toolColor.
  ///
  /// In ru, this message translates to:
  /// **'Цвет'**
  String get toolColor;

  /// No description provided for @toolColorDesc.
  ///
  /// In ru, this message translates to:
  /// **'Яркость, контраст, кривые, 3D LUT, ч/б и сепия.'**
  String get toolColorDesc;

  /// No description provided for @toolOverlay.
  ///
  /// In ru, this message translates to:
  /// **'Водяной знак и текст'**
  String get toolOverlay;

  /// No description provided for @toolOverlayDesc.
  ///
  /// In ru, this message translates to:
  /// **'Картинка, текст или таймкод поверх видео.'**
  String get toolOverlayDesc;

  /// No description provided for @toolBlur.
  ///
  /// In ru, this message translates to:
  /// **'Размытие и логотипы'**
  String get toolBlur;

  /// No description provided for @toolBlurDesc.
  ///
  /// In ru, this message translates to:
  /// **'Размыть или пикселизовать область, убрать логотип.'**
  String get toolBlurDesc;

  /// No description provided for @toolStack.
  ///
  /// In ru, this message translates to:
  /// **'Картинка в картинке'**
  String get toolStack;

  /// No description provided for @toolStackDesc.
  ///
  /// In ru, this message translates to:
  /// **'PiP, сетка, сравнение бок о бок.'**
  String get toolStackDesc;

  /// No description provided for @toolTransitions.
  ///
  /// In ru, this message translates to:
  /// **'Затухания и переходы'**
  String get toolTransitions;

  /// No description provided for @toolTransitionsDesc.
  ///
  /// In ru, this message translates to:
  /// **'Fade in/out и все виды переходов xfade.'**
  String get toolTransitionsDesc;

  /// No description provided for @toolLoop.
  ///
  /// In ru, this message translates to:
  /// **'Кольцевание'**
  String get toolLoop;

  /// No description provided for @toolLoopDesc.
  ///
  /// In ru, this message translates to:
  /// **'Повтор видео и бумеранг.'**
  String get toolLoopDesc;

  /// No description provided for @toolExtractAudio.
  ///
  /// In ru, this message translates to:
  /// **'Извлечь звук'**
  String get toolExtractAudio;

  /// No description provided for @toolExtractAudioDesc.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить звуковую дорожку отдельным файлом.'**
  String get toolExtractAudioDesc;

  /// No description provided for @toolReplaceAudio.
  ///
  /// In ru, this message translates to:
  /// **'Дорожки звука'**
  String get toolReplaceAudio;

  /// No description provided for @toolReplaceAudioDesc.
  ///
  /// In ru, this message translates to:
  /// **'Заменить, добавить, удалить дорожку или выбрать основную.'**
  String get toolReplaceAudioDesc;

  /// No description provided for @toolNormalize.
  ///
  /// In ru, this message translates to:
  /// **'Нормализация громкости'**
  String get toolNormalize;

  /// No description provided for @toolNormalizeDesc.
  ///
  /// In ru, this message translates to:
  /// **'Двухпроходная loudnorm: YouTube −14, подкаст −16, ТВ −23 LUFS.'**
  String get toolNormalizeDesc;

  /// No description provided for @toolDenoise.
  ///
  /// In ru, this message translates to:
  /// **'Шумоподавление'**
  String get toolDenoise;

  /// No description provided for @toolDenoiseDesc.
  ///
  /// In ru, this message translates to:
  /// **'afftdn, anlmdn, RNNoise, удаление щелчков и клиппинга.'**
  String get toolDenoiseDesc;

  /// No description provided for @toolAudioFx.
  ///
  /// In ru, this message translates to:
  /// **'Обработка звука'**
  String get toolAudioFx;

  /// No description provided for @toolAudioFxDesc.
  ///
  /// In ru, this message translates to:
  /// **'Эквалайзер, компрессор, лимитер, темп и тон, каналы.'**
  String get toolAudioFxDesc;

  /// No description provided for @toolMix.
  ///
  /// In ru, this message translates to:
  /// **'Смешивание'**
  String get toolMix;

  /// No description provided for @toolMixDesc.
  ///
  /// In ru, this message translates to:
  /// **'Несколько дорожек вместе, автоприглушение музыки под голос.'**
  String get toolMixDesc;

  /// No description provided for @toolTranscribe.
  ///
  /// In ru, this message translates to:
  /// **'Транскрипция'**
  String get toolTranscribe;

  /// No description provided for @toolTranscribeDesc.
  ///
  /// In ru, this message translates to:
  /// **'Распознать речь в субтитры через whisper.'**
  String get toolTranscribeDesc;

  /// No description provided for @toolBurnSubs.
  ///
  /// In ru, this message translates to:
  /// **'Вшить субтитры'**
  String get toolBurnSubs;

  /// No description provided for @toolBurnSubsDesc.
  ///
  /// In ru, this message translates to:
  /// **'Субтитры прямо в картинке, со стилями.'**
  String get toolBurnSubsDesc;

  /// No description provided for @toolSoftSubs.
  ///
  /// In ru, this message translates to:
  /// **'Дорожки субтитров'**
  String get toolSoftSubs;

  /// No description provided for @toolSoftSubsDesc.
  ///
  /// In ru, this message translates to:
  /// **'Добавить, извлечь или удалить отдельную дорожку.'**
  String get toolSoftSubsDesc;

  /// No description provided for @toolConvertSubs.
  ///
  /// In ru, this message translates to:
  /// **'Конвертация субтитров'**
  String get toolConvertSubs;

  /// No description provided for @toolConvertSubsDesc.
  ///
  /// In ru, this message translates to:
  /// **'SRT ↔ ASS ↔ VTT, сдвиг таймингов, кодировка.'**
  String get toolConvertSubsDesc;

  /// No description provided for @toolGif.
  ///
  /// In ru, this message translates to:
  /// **'GIF и анимации'**
  String get toolGif;

  /// No description provided for @toolGifDesc.
  ///
  /// In ru, this message translates to:
  /// **'Качественный GIF с палитрой, анимированные WebP и APNG.'**
  String get toolGifDesc;

  /// No description provided for @toolFrames.
  ///
  /// In ru, this message translates to:
  /// **'Извлечь кадры'**
  String get toolFrames;

  /// No description provided for @toolFramesDesc.
  ///
  /// In ru, this message translates to:
  /// **'Каждый N-й кадр, по сценам или в заданное время.'**
  String get toolFramesDesc;

  /// No description provided for @toolContactSheet.
  ///
  /// In ru, this message translates to:
  /// **'Раскадровка'**
  String get toolContactSheet;

  /// No description provided for @toolContactSheetDesc.
  ///
  /// In ru, this message translates to:
  /// **'Сетка миниатюр из видео.'**
  String get toolContactSheetDesc;

  /// No description provided for @toolSlideshow.
  ///
  /// In ru, this message translates to:
  /// **'Слайд-шоу'**
  String get toolSlideshow;

  /// No description provided for @toolSlideshowDesc.
  ///
  /// In ru, this message translates to:
  /// **'Видео из картинок с переходами.'**
  String get toolSlideshowDesc;

  /// No description provided for @toolAudioToVideo.
  ///
  /// In ru, this message translates to:
  /// **'Картинка + звук'**
  String get toolAudioToVideo;

  /// No description provided for @toolAudioToVideoDesc.
  ///
  /// In ru, this message translates to:
  /// **'Видео из обложки и аудио, например для YouTube.'**
  String get toolAudioToVideoDesc;

  /// No description provided for @toolVisualizer.
  ///
  /// In ru, this message translates to:
  /// **'Визуализатор звука'**
  String get toolVisualizer;

  /// No description provided for @toolVisualizerDesc.
  ///
  /// In ru, this message translates to:
  /// **'Волна, спектр или вектороскоп в видео.'**
  String get toolVisualizerDesc;

  /// No description provided for @toolImageConvert.
  ///
  /// In ru, this message translates to:
  /// **'Конвертация картинок'**
  String get toolImageConvert;

  /// No description provided for @toolImageConvertDesc.
  ///
  /// In ru, this message translates to:
  /// **'JPEG, PNG, WebP, AVIF: сжатие и смена формата.'**
  String get toolImageConvertDesc;

  /// No description provided for @toolTags.
  ///
  /// In ru, this message translates to:
  /// **'Теги'**
  String get toolTags;

  /// No description provided for @toolTagsDesc.
  ///
  /// In ru, this message translates to:
  /// **'Название, исполнитель, альбом, год и прочее.'**
  String get toolTagsDesc;

  /// No description provided for @toolCover.
  ///
  /// In ru, this message translates to:
  /// **'Обложка'**
  String get toolCover;

  /// No description provided for @toolCoverDesc.
  ///
  /// In ru, this message translates to:
  /// **'Добавить, заменить или извлечь обложку.'**
  String get toolCoverDesc;

  /// No description provided for @toolChapters.
  ///
  /// In ru, this message translates to:
  /// **'Главы'**
  String get toolChapters;

  /// No description provided for @toolChaptersDesc.
  ///
  /// In ru, this message translates to:
  /// **'Добавить, переименовать, импорт и экспорт глав.'**
  String get toolChaptersDesc;

  /// No description provided for @toolScreenRecord.
  ///
  /// In ru, this message translates to:
  /// **'Запись экрана'**
  String get toolScreenRecord;

  /// No description provided for @toolScreenRecordDesc.
  ///
  /// In ru, this message translates to:
  /// **'Весь экран, область или окно.'**
  String get toolScreenRecordDesc;

  /// No description provided for @toolWebcam.
  ///
  /// In ru, this message translates to:
  /// **'Камера и микрофон'**
  String get toolWebcam;

  /// No description provided for @toolWebcamDesc.
  ///
  /// In ru, this message translates to:
  /// **'Запись с веб-камеры и микрофона.'**
  String get toolWebcamDesc;

  /// No description provided for @toolStream.
  ///
  /// In ru, this message translates to:
  /// **'Стрим'**
  String get toolStream;

  /// No description provided for @toolStreamDesc.
  ///
  /// In ru, this message translates to:
  /// **'RTMP / SRT на YouTube, Twitch или свой сервер.'**
  String get toolStreamDesc;

  /// No description provided for @toolHls.
  ///
  /// In ru, this message translates to:
  /// **'HLS / DASH'**
  String get toolHls;

  /// No description provided for @toolHlsDesc.
  ///
  /// In ru, this message translates to:
  /// **'Упаковка для воспроизведения в браузере.'**
  String get toolHlsDesc;

  /// No description provided for @toolRepair.
  ///
  /// In ru, this message translates to:
  /// **'Ремонт'**
  String get toolRepair;

  /// No description provided for @toolRepairDesc.
  ///
  /// In ru, this message translates to:
  /// **'Ремукс битых файлов, таймстемпы, рассинхрон.'**
  String get toolRepairDesc;

  /// No description provided for @toolFaststart.
  ///
  /// In ru, this message translates to:
  /// **'Faststart для MP4'**
  String get toolFaststart;

  /// No description provided for @toolFaststartDesc.
  ///
  /// In ru, this message translates to:
  /// **'Быстрый старт видео в браузере.'**
  String get toolFaststartDesc;

  /// No description provided for @toolDownload.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка по ссылке'**
  String get toolDownload;

  /// No description provided for @toolDownloadDesc.
  ///
  /// In ru, this message translates to:
  /// **'Видео и аудио с сайтов через yt-dlp.'**
  String get toolDownloadDesc;

  /// No description provided for @toolBatch.
  ///
  /// In ru, this message translates to:
  /// **'Пакетная обработка'**
  String get toolBatch;

  /// No description provided for @toolBatchDesc.
  ///
  /// In ru, this message translates to:
  /// **'Одна операция для папки или набора файлов.'**
  String get toolBatchDesc;

  /// No description provided for @toolRecipes.
  ///
  /// In ru, this message translates to:
  /// **'Рецепты'**
  String get toolRecipes;

  /// No description provided for @toolRecipesDesc.
  ///
  /// In ru, this message translates to:
  /// **'Цепочки операций: обрезать → нормализовать → сжать.'**
  String get toolRecipesDesc;

  /// No description provided for @toolWatchFolder.
  ///
  /// In ru, this message translates to:
  /// **'Наблюдение за папкой'**
  String get toolWatchFolder;

  /// No description provided for @toolWatchFolderDesc.
  ///
  /// In ru, this message translates to:
  /// **'Новые файлы обрабатываются автоматически.'**
  String get toolWatchFolderDesc;

  /// No description provided for @toolCommandEditor.
  ///
  /// In ru, this message translates to:
  /// **'Редактор команд'**
  String get toolCommandEditor;

  /// No description provided for @toolCommandEditorDesc.
  ///
  /// In ru, this message translates to:
  /// **'Своя команда ffmpeg с автодополнением.'**
  String get toolCommandEditorDesc;

  /// No description provided for @toolFilterGraph.
  ///
  /// In ru, this message translates to:
  /// **'Конструктор фильтров'**
  String get toolFilterGraph;

  /// No description provided for @toolFilterGraphDesc.
  ///
  /// In ru, this message translates to:
  /// **'Цепочка фильтров списком с параметрами.'**
  String get toolFilterGraphDesc;

  /// No description provided for @toolCommandLog.
  ///
  /// In ru, this message translates to:
  /// **'Журнал команд'**
  String get toolCommandLog;

  /// No description provided for @toolCommandLogDesc.
  ///
  /// In ru, this message translates to:
  /// **'Все запущенные команды с логами.'**
  String get toolCommandLogDesc;

  /// No description provided for @queueEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Очередь пуста'**
  String get queueEmptyTitle;

  /// No description provided for @queueEmptyBody.
  ///
  /// In ru, this message translates to:
  /// **'Задачи из инструментов появятся здесь с прогрессом, скоростью и оставшимся временем.'**
  String get queueEmptyBody;

  /// No description provided for @queueActive.
  ///
  /// In ru, this message translates to:
  /// **'В работе и в очереди'**
  String get queueActive;

  /// No description provided for @queueHistory.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get queueHistory;

  /// No description provided for @clearFinished.
  ///
  /// In ru, this message translates to:
  /// **'Очистить завершённые'**
  String get clearFinished;

  /// No description provided for @parallelJobsShort.
  ///
  /// In ru, this message translates to:
  /// **'Параллельно: {count}'**
  String parallelJobsShort(int count);

  /// No description provided for @statusQueued.
  ///
  /// In ru, this message translates to:
  /// **'В очереди'**
  String get statusQueued;

  /// No description provided for @statusRunning.
  ///
  /// In ru, this message translates to:
  /// **'Выполняется'**
  String get statusRunning;

  /// No description provided for @statusPaused.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get statusPaused;

  /// No description provided for @statusCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get statusCompleted;

  /// No description provided for @statusCompletedWithFindings.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Найдена {count} проблема} few{Найдено {count} проблемы} many{Найдено {count} проблем} other{Найдено {count} проблемы}}'**
  String statusCompletedWithFindings(int count);

  /// No description provided for @statusNoProblems.
  ///
  /// In ru, this message translates to:
  /// **'Ошибок не найдено'**
  String get statusNoProblems;

  /// No description provided for @statusFailed.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get statusFailed;

  /// No description provided for @statusCanceled.
  ///
  /// In ru, this message translates to:
  /// **'Отменено'**
  String get statusCanceled;

  /// No description provided for @etaLabel.
  ///
  /// In ru, this message translates to:
  /// **'осталось {time}'**
  String etaLabel(String time);

  /// No description provided for @tookLabel.
  ///
  /// In ru, this message translates to:
  /// **'заняло {time}'**
  String tookLabel(String time);

  /// No description provided for @attemptsLabel.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} попытка} few{{count} попытки} many{{count} попыток} other{{count} попытки}}'**
  String attemptsLabel(int count);

  /// No description provided for @priorityHigh.
  ///
  /// In ru, this message translates to:
  /// **'Высокий приоритет'**
  String get priorityHigh;

  /// No description provided for @priorityRaise.
  ///
  /// In ru, this message translates to:
  /// **'Поднять приоритет'**
  String get priorityRaise;

  /// No description provided for @priorityNormal.
  ///
  /// In ru, this message translates to:
  /// **'Обычный приоритет'**
  String get priorityNormal;

  /// No description provided for @errToolMissing.
  ///
  /// In ru, this message translates to:
  /// **'Не найден нужный инструмент. Установите его в разделе «Компоненты».'**
  String get errToolMissing;

  /// No description provided for @errFileNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Файл не найден: {path}'**
  String errFileNotFound(String path);

  /// No description provided for @errPermissionDenied.
  ///
  /// In ru, this message translates to:
  /// **'Нет доступа к файлу или папке: {path}. Выберите другую папку для сохранения.'**
  String errPermissionDenied(String path);

  /// No description provided for @errDiskFull.
  ///
  /// In ru, this message translates to:
  /// **'Закончилось место на диске.'**
  String get errDiskFull;

  /// No description provided for @errInvalidData.
  ///
  /// In ru, this message translates to:
  /// **'Файл повреждён или его формат не поддерживается. Попробуйте «Ремонт» или «Проверку целостности».'**
  String get errInvalidData;

  /// No description provided for @errEncoderMissing.
  ///
  /// In ru, this message translates to:
  /// **'В этой сборке ffmpeg нет кодировщика «{name}». Выберите другой кодек или установите full-сборку.'**
  String errEncoderMissing(String name);

  /// No description provided for @errDecoderMissing.
  ///
  /// In ru, this message translates to:
  /// **'В этой сборке ffmpeg нет декодера «{name}».'**
  String errDecoderMissing(String name);

  /// No description provided for @errFilterMissing.
  ///
  /// In ru, this message translates to:
  /// **'В этой сборке ffmpeg нет фильтра «{name}». Установите full-сборку в «Компонентах».'**
  String errFilterMissing(String name);

  /// No description provided for @errCodecContainer.
  ///
  /// In ru, this message translates to:
  /// **'Кодек не поддерживается этим контейнером. Попробуйте MKV — он принимает почти всё.'**
  String get errCodecContainer;

  /// No description provided for @errOddDimensions.
  ///
  /// In ru, this message translates to:
  /// **'Ширина и высота должны быть чётными для этого кодека. Включите округление размера.'**
  String get errOddDimensions;

  /// No description provided for @errHwUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Аппаратный кодировщик недоступен (нет видеокарты или драйвера). Отключите ускорение или выберите программный кодек.'**
  String get errHwUnavailable;

  /// No description provided for @errInvalidArgument.
  ///
  /// In ru, this message translates to:
  /// **'Неверный параметр: {arg}'**
  String errInvalidArgument(String arg);

  /// No description provided for @errStreamNotFound.
  ///
  /// In ru, this message translates to:
  /// **'В файле нет выбранной дорожки.'**
  String get errStreamNotFound;

  /// No description provided for @errSameAsInput.
  ///
  /// In ru, this message translates to:
  /// **'Результат нельзя записать поверх исходного файла. Выберите другое имя.'**
  String get errSameAsInput;

  /// No description provided for @errNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Проблема с сетью. Проверьте подключение и попробуйте снова.'**
  String get errNetwork;

  /// No description provided for @errUnsupportedUrl.
  ///
  /// In ru, this message translates to:
  /// **'Этот сайт или ссылка не поддерживаются.'**
  String get errUnsupportedUrl;

  /// No description provided for @errLoginRequired.
  ///
  /// In ru, this message translates to:
  /// **'Нужен вход в аккаунт. Включите cookies из браузера в настройках загрузок.'**
  String get errLoginRequired;

  /// No description provided for @errVideoUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Видео недоступно: удалено, приватное или заблокировано в регионе.'**
  String get errVideoUnavailable;

  /// No description provided for @errCanceled.
  ///
  /// In ru, this message translates to:
  /// **'Отменено.'**
  String get errCanceled;

  /// No description provided for @errUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось. Подробности в полном логе.'**
  String get errUnknown;

  /// No description provided for @checkUpdates.
  ///
  /// In ru, this message translates to:
  /// **'Проверить обновления'**
  String get checkUpdates;

  /// No description provided for @lastChecked.
  ///
  /// In ru, this message translates to:
  /// **'Проверено в {time}'**
  String lastChecked(String time);

  /// No description provided for @compFfmpeg.
  ///
  /// In ru, this message translates to:
  /// **'ffmpeg и ffprobe'**
  String get compFfmpeg;

  /// No description provided for @compFfmpegDesc.
  ///
  /// In ru, this message translates to:
  /// **'Основной движок: конвертация, фильтры, анализ. Обязателен.'**
  String get compFfmpegDesc;

  /// No description provided for @compYtdlp.
  ///
  /// In ru, this message translates to:
  /// **'yt-dlp'**
  String get compYtdlp;

  /// No description provided for @compYtdlpDesc.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка видео и аудио с YouTube и тысяч других сайтов.'**
  String get compYtdlpDesc;

  /// No description provided for @compDeno.
  ///
  /// In ru, this message translates to:
  /// **'Deno'**
  String get compDeno;

  /// No description provided for @compDenoDesc.
  ///
  /// In ru, this message translates to:
  /// **'JavaScript-рантайм, который нужен yt-dlp для YouTube.'**
  String get compDenoDesc;

  /// No description provided for @compAria2.
  ///
  /// In ru, this message translates to:
  /// **'aria2c'**
  String get compAria2;

  /// No description provided for @compAria2Desc.
  ///
  /// In ru, this message translates to:
  /// **'Ускоренная многопоточная загрузка для yt-dlp.'**
  String get compAria2Desc;

  /// No description provided for @originCustom.
  ///
  /// In ru, this message translates to:
  /// **'свой путь'**
  String get originCustom;

  /// No description provided for @originManaged.
  ///
  /// In ru, this message translates to:
  /// **'установлен приложением'**
  String get originManaged;

  /// No description provided for @originSystem.
  ///
  /// In ru, this message translates to:
  /// **'системный'**
  String get originSystem;

  /// No description provided for @originNone.
  ///
  /// In ru, this message translates to:
  /// **'не найден'**
  String get originNone;

  /// No description provided for @updateAvailable.
  ///
  /// In ru, this message translates to:
  /// **'есть обновление'**
  String get updateAvailable;

  /// No description provided for @inUse.
  ///
  /// In ru, this message translates to:
  /// **'Используется'**
  String get inUse;

  /// No description provided for @installedVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get installedVersion;

  /// No description provided for @sourceLabel.
  ///
  /// In ru, this message translates to:
  /// **'Источник'**
  String get sourceLabel;

  /// No description provided for @latestAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Доступно'**
  String get latestAvailable;

  /// No description provided for @noChecksum.
  ///
  /// In ru, this message translates to:
  /// **'издатель не публикует SHA-256'**
  String get noChecksum;

  /// No description provided for @removeComponentConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить «{name}» и все сохранённые версии?'**
  String removeComponentConfirm(String name);

  /// No description provided for @componentError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: {error}'**
  String componentError(String error);

  /// No description provided for @versionHistory.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Установленные версии ({count})} other{Установленные версии ({count})}}'**
  String versionHistory(int count);

  /// No description provided for @phaseResolving.
  ///
  /// In ru, this message translates to:
  /// **'Поиск последней версии…'**
  String get phaseResolving;

  /// No description provided for @phaseDownloading.
  ///
  /// In ru, this message translates to:
  /// **'Скачивание'**
  String get phaseDownloading;

  /// No description provided for @phaseVerifying.
  ///
  /// In ru, this message translates to:
  /// **'Проверка SHA-256…'**
  String get phaseVerifying;

  /// No description provided for @phaseExtracting.
  ///
  /// In ru, this message translates to:
  /// **'Распаковка…'**
  String get phaseExtracting;

  /// No description provided for @phaseTesting.
  ///
  /// In ru, this message translates to:
  /// **'Проверка запуска…'**
  String get phaseTesting;

  /// No description provided for @flavorFull.
  ///
  /// In ru, this message translates to:
  /// **'full'**
  String get flavorFull;

  /// No description provided for @flavorEssentials.
  ///
  /// In ru, this message translates to:
  /// **'essentials'**
  String get flavorEssentials;

  /// No description provided for @channelRelease.
  ///
  /// In ru, this message translates to:
  /// **'релиз'**
  String get channelRelease;

  /// No description provided for @channelNightly.
  ///
  /// In ru, this message translates to:
  /// **'nightly'**
  String get channelNightly;

  /// No description provided for @channelStable.
  ///
  /// In ru, this message translates to:
  /// **'stable'**
  String get channelStable;

  /// No description provided for @btbnHint.
  ///
  /// In ru, this message translates to:
  /// **'Статические сборки BtbN. GPL — всё, включая x264/x265; LGPL — без GPL-кодеков.'**
  String get btbnHint;

  /// No description provided for @gyanHint.
  ///
  /// In ru, this message translates to:
  /// **'Сборки gyan.dev для Windows. full — максимум фильтров и кодеков (whisper, vmaf, frei0r).'**
  String get gyanHint;

  /// No description provided for @customPathNone.
  ///
  /// In ru, this message translates to:
  /// **'Можно указать свой бинарник вместо загруженного.'**
  String get customPathNone;

  /// No description provided for @customPathValue.
  ///
  /// In ru, this message translates to:
  /// **'Используется свой путь: {path}'**
  String customPathValue(String path);

  /// No description provided for @useCustomBinary.
  ///
  /// In ru, this message translates to:
  /// **'Указать свой'**
  String get useCustomBinary;

  /// No description provided for @installViaPackageManager.
  ///
  /// In ru, this message translates to:
  /// **'Установите пакет «{pkg}» через менеджер пакетов системы.'**
  String installViaPackageManager(String pkg);

  /// No description provided for @buildInfoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Возможности сборки ffmpeg'**
  String get buildInfoTitle;

  /// No description provided for @licenseLabel.
  ///
  /// In ru, this message translates to:
  /// **'Лицензия'**
  String get licenseLabel;

  /// No description provided for @encoders.
  ///
  /// In ru, this message translates to:
  /// **'Кодировщики'**
  String get encoders;

  /// No description provided for @decoders.
  ///
  /// In ru, this message translates to:
  /// **'Декодеры'**
  String get decoders;

  /// No description provided for @filters.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filters;

  /// No description provided for @muxers.
  ///
  /// In ru, this message translates to:
  /// **'Контейнеры'**
  String get muxers;

  /// No description provided for @configuration.
  ///
  /// In ru, this message translates to:
  /// **'Конфигурация'**
  String get configuration;

  /// No description provided for @hwTitle.
  ///
  /// In ru, this message translates to:
  /// **'Аппаратное ускорение'**
  String get hwTitle;

  /// No description provided for @redetect.
  ///
  /// In ru, this message translates to:
  /// **'Перепроверить'**
  String get redetect;

  /// No description provided for @hwDetecting.
  ///
  /// In ru, this message translates to:
  /// **'Пробное кодирование на каждом ускорителе…'**
  String get hwDetecting;

  /// No description provided for @hwDecode.
  ///
  /// In ru, this message translates to:
  /// **'Декодирование'**
  String get hwDecode;

  /// No description provided for @hwBestDecode.
  ///
  /// In ru, this message translates to:
  /// **'Лучшее для декодирования'**
  String get hwBestDecode;

  /// No description provided for @hwEncoders.
  ///
  /// In ru, this message translates to:
  /// **'Рабочие кодировщики'**
  String get hwEncoders;

  /// No description provided for @hwSoftwareOnly.
  ///
  /// In ru, this message translates to:
  /// **'только программно'**
  String get hwSoftwareOnly;

  /// No description provided for @hwNoneWorking.
  ///
  /// In ru, this message translates to:
  /// **'не найдено, кодирование будет на процессоре'**
  String get hwNoneWorking;

  /// No description provided for @hwFailed.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Не прошёл проверку: {count}} other{Не прошли проверку: {count}}}'**
  String hwFailed(int count);

  /// No description provided for @plannedComponents.
  ///
  /// In ru, this message translates to:
  /// **'Скоро'**
  String get plannedComponents;

  /// No description provided for @compRnnoise.
  ///
  /// In ru, this message translates to:
  /// **'Модели RNNoise (шумоподавление голоса)'**
  String get compRnnoise;

  /// No description provided for @compVmaf.
  ///
  /// In ru, this message translates to:
  /// **'Модели VMAF (оценка качества)'**
  String get compVmaf;

  /// No description provided for @compWhisper.
  ///
  /// In ru, this message translates to:
  /// **'Модели whisper.cpp (транскрипция)'**
  String get compWhisper;

  /// No description provided for @compFrei0r.
  ///
  /// In ru, this message translates to:
  /// **'frei0r и LADSPA/LV2 плагины'**
  String get compFrei0r;

  /// No description provided for @compLuts.
  ///
  /// In ru, this message translates to:
  /// **'3D LUT-пакеты (.cube)'**
  String get compLuts;

  /// No description provided for @compFonts.
  ///
  /// In ru, this message translates to:
  /// **'Шрифты для субтитров и текста'**
  String get compFonts;

  /// No description provided for @downloadsSoonTitle.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка по ссылкам — на этапе 2'**
  String get downloadsSoonTitle;

  /// No description provided for @downloadsReady.
  ///
  /// In ru, this message translates to:
  /// **'yt-dlp готов: {path}'**
  String downloadsReady(String path);

  /// No description provided for @downloadsNeedYtdlp.
  ///
  /// In ru, this message translates to:
  /// **'Для загрузки понадобится yt-dlp. Его можно установить уже сейчас.'**
  String get downloadsNeedYtdlp;

  /// No description provided for @presetsSoonTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пресеты появятся вместе с конвертацией'**
  String get presetsSoonTitle;

  /// No description provided for @presetsSoonBody.
  ///
  /// In ru, this message translates to:
  /// **'«Для Telegram», «Для YouTube», «Для Discord (до 10 МБ)», «Для монтажа», «Архив без потерь» и свои пресеты с экспортом в JSON.'**
  String get presetsSoonBody;

  /// No description provided for @settingsSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по настройкам'**
  String get settingsSearchHint;

  /// No description provided for @showAdvanced.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Показать ещё {count} расширенную настройку} few{Показать ещё {count} расширенные настройки} many{Показать ещё {count} расширенных настроек} other{Показать ещё {count} расширенной настройки}}'**
  String showAdvanced(int count);

  /// No description provided for @secGeneral.
  ///
  /// In ru, this message translates to:
  /// **'Общие'**
  String get secGeneral;

  /// No description provided for @secAppearance.
  ///
  /// In ru, this message translates to:
  /// **'Внешний вид'**
  String get secAppearance;

  /// No description provided for @secPerformance.
  ///
  /// In ru, this message translates to:
  /// **'Производительность'**
  String get secPerformance;

  /// No description provided for @secPaths.
  ///
  /// In ru, this message translates to:
  /// **'Пути и папки'**
  String get secPaths;

  /// No description provided for @secDownloads.
  ///
  /// In ru, this message translates to:
  /// **'Загрузки (yt-dlp)'**
  String get secDownloads;

  /// No description provided for @secUpdates.
  ///
  /// In ru, this message translates to:
  /// **'Компоненты и обновления'**
  String get secUpdates;

  /// No description provided for @secNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get secNotifications;

  /// No description provided for @secExpert.
  ///
  /// In ru, this message translates to:
  /// **'Для экспертов'**
  String get secExpert;

  /// No description provided for @setLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык интерфейса'**
  String get setLanguage;

  /// No description provided for @setLanguageHint.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию — как в системе'**
  String get setLanguageHint;

  /// No description provided for @languageSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get languageSystem;

  /// No description provided for @setAdvancedMode.
  ///
  /// In ru, this message translates to:
  /// **'Расширенный режим'**
  String get setAdvancedMode;

  /// No description provided for @setAdvancedModeHint.
  ///
  /// In ru, this message translates to:
  /// **'Показывать все параметры, а не только главные'**
  String get setAdvancedModeHint;

  /// No description provided for @setAdvancedModeHelp.
  ///
  /// In ru, this message translates to:
  /// **'В простом режиме у инструментов и в настройках видны только параметры, которые нужны в 90% случаев; остальные берут разумные значения по умолчанию. Расширенный режим открывает всё: профили и уровни кодеков, пиксельные форматы, число потоков и т. п. Поиск находит расширенные настройки в любом режиме. По умолчанию: выключен.'**
  String get setAdvancedModeHelp;

  /// No description provided for @setTheme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get setTheme;

  /// No description provided for @setThemeHint.
  ///
  /// In ru, this message translates to:
  /// **'Светлая, тёмная или как в системе'**
  String get setThemeHint;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системная'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @setAccent.
  ///
  /// In ru, this message translates to:
  /// **'Акцентный цвет'**
  String get setAccent;

  /// No description provided for @setAccentHint.
  ///
  /// In ru, this message translates to:
  /// **'Цвет кнопок и выделений'**
  String get setAccentHint;

  /// No description provided for @setAccentHelp.
  ///
  /// In ru, this message translates to:
  /// **'«Системный» берёт акцент из настроек Windows или GNOME/KDE (Material You). Если система цвет не сообщает, используется выбранный ниже. По умолчанию: системный.'**
  String get setAccentHelp;

  /// No description provided for @accentSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системный'**
  String get accentSystem;

  /// No description provided for @accentCustom.
  ///
  /// In ru, this message translates to:
  /// **'Свой'**
  String get accentCustom;

  /// No description provided for @setParallel.
  ///
  /// In ru, this message translates to:
  /// **'Параллельные задачи'**
  String get setParallel;

  /// No description provided for @setParallelHint.
  ///
  /// In ru, this message translates to:
  /// **'Сколько задач очереди выполнять одновременно'**
  String get setParallelHint;

  /// No description provided for @setParallelHelp.
  ///
  /// In ru, this message translates to:
  /// **'ffmpeg и так использует все ядра процессора, поэтому для перекодирования обычно лучше 1–2 задачи: каждая закончится быстрее. Больше задач выгодно для лёгких операций (ремукс, обрезка без перекодирования, загрузки) и при аппаратном кодировании, где видеокарта может вести несколько потоков. Рекомендуется: 1–2. По умолчанию: 1.'**
  String get setParallelHelp;

  /// No description provided for @zoneFasterEach.
  ///
  /// In ru, this message translates to:
  /// **'каждая быстрее'**
  String get zoneFasterEach;

  /// No description provided for @zoneMoreAtOnce.
  ///
  /// In ru, this message translates to:
  /// **'больше сразу'**
  String get zoneMoreAtOnce;

  /// No description provided for @setHwAccel.
  ///
  /// In ru, this message translates to:
  /// **'Аппаратное ускорение'**
  String get setHwAccel;

  /// No description provided for @setHwAccelHint.
  ///
  /// In ru, this message translates to:
  /// **'Кодировать на видеокарте, если она найдена'**
  String get setHwAccelHint;

  /// No description provided for @setHwAccelHelp.
  ///
  /// In ru, this message translates to:
  /// **'NVENC (NVIDIA), Quick Sync (Intel), AMF (AMD), VAAPI и Vulkan кодируют в разы быстрее процессора, но при том же размере файла качество немного ниже. Для архива и максимального качества выключите. Что именно найдено, видно в «Компонентах». По умолчанию: включено.'**
  String get setHwAccelHelp;

  /// No description provided for @setRetries.
  ///
  /// In ru, this message translates to:
  /// **'Повторы при ошибке'**
  String get setRetries;

  /// No description provided for @setRetriesHint.
  ///
  /// In ru, this message translates to:
  /// **'Сколько раз перезапускать упавшую задачу'**
  String get setRetriesHint;

  /// No description provided for @setRetriesHelp.
  ///
  /// In ru, this message translates to:
  /// **'Полезно для загрузок и сетевых источников, где сбои бывают временными. Для локальных файлов ошибка обычно повторяется, поэтому по умолчанию: 0.'**
  String get setRetriesHelp;

  /// No description provided for @setThreads.
  ///
  /// In ru, this message translates to:
  /// **'Потоки ffmpeg'**
  String get setThreads;

  /// No description provided for @setThreadsHint.
  ///
  /// In ru, this message translates to:
  /// **'Ограничить число потоков процессора на задачу'**
  String get setThreadsHint;

  /// No description provided for @setThreadsHelp.
  ///
  /// In ru, this message translates to:
  /// **'«авто» позволяет ffmpeg самому выбрать оптимум. Ограничение нужно, если вы хотите оставить процессор свободным для других программ во время кодирования. По умолчанию: авто.'**
  String get setThreadsHelp;

  /// No description provided for @setOutputDir.
  ///
  /// In ru, this message translates to:
  /// **'Папка для результатов'**
  String get setOutputDir;

  /// No description provided for @setOutputDirHint.
  ///
  /// In ru, this message translates to:
  /// **'Куда сохранять готовые файлы'**
  String get setOutputDirHint;

  /// No description provided for @setOutputDirHelp.
  ///
  /// In ru, this message translates to:
  /// **'Если не задана, результаты сохраняются в папку «Kadra» внутри «Видео» (или домашней папки). Каждый инструмент также позволяет выбрать место вручную.'**
  String get setOutputDirHelp;

  /// No description provided for @outputDirDefault.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию: {path}'**
  String outputDirDefault(String path);

  /// No description provided for @setCustomFfmpeg.
  ///
  /// In ru, this message translates to:
  /// **'Свой ffmpeg'**
  String get setCustomFfmpeg;

  /// No description provided for @setCustomFfmpegHint.
  ///
  /// In ru, this message translates to:
  /// **'Путь к уже установленному ffmpeg'**
  String get setCustomFfmpegHint;

  /// No description provided for @setCustomFfmpegHelp.
  ///
  /// In ru, this message translates to:
  /// **'Имеет приоритет над загруженным компонентом и системным PATH. ffprobe ищется рядом автоматически. Полезно, если у вас своя сборка с нестандартными библиотеками.'**
  String get setCustomFfmpegHelp;

  /// No description provided for @setCustomFfprobe.
  ///
  /// In ru, this message translates to:
  /// **'Свой ffprobe'**
  String get setCustomFfprobe;

  /// No description provided for @setCustomFfprobeHint.
  ///
  /// In ru, this message translates to:
  /// **'Если он лежит не рядом с ffmpeg'**
  String get setCustomFfprobeHint;

  /// No description provided for @setCustomYtdlp.
  ///
  /// In ru, this message translates to:
  /// **'Свой yt-dlp'**
  String get setCustomYtdlp;

  /// No description provided for @setCustomYtdlpHint.
  ///
  /// In ru, this message translates to:
  /// **'Путь к уже установленному yt-dlp'**
  String get setCustomYtdlpHint;

  /// No description provided for @setFragments.
  ///
  /// In ru, this message translates to:
  /// **'Параллельные фрагменты'**
  String get setFragments;

  /// No description provided for @setFragmentsHint.
  ///
  /// In ru, this message translates to:
  /// **'Сколько частей видео качать одновременно'**
  String get setFragmentsHint;

  /// No description provided for @setFragmentsHelp.
  ///
  /// In ru, this message translates to:
  /// **'yt-dlp --concurrent-fragments. Ускоряет загрузку потоковых форматов (DASH/HLS) с YouTube и других сайтов. Слишком большое значение может привести к временной блокировке со стороны сайта. Рекомендуется: 4–8. По умолчанию: 4.'**
  String get setFragmentsHelp;

  /// No description provided for @zoneGentle.
  ///
  /// In ru, this message translates to:
  /// **'бережнее к сайту'**
  String get zoneGentle;

  /// No description provided for @zoneFaster.
  ///
  /// In ru, this message translates to:
  /// **'быстрее'**
  String get zoneFaster;

  /// No description provided for @setPolicyFfmpeg.
  ///
  /// In ru, this message translates to:
  /// **'Обновления ffmpeg'**
  String get setPolicyFfmpeg;

  /// No description provided for @setPolicyHint.
  ///
  /// In ru, this message translates to:
  /// **'Что делать, когда вышла новая версия'**
  String get setPolicyHint;

  /// No description provided for @setPolicyYtdlp.
  ///
  /// In ru, this message translates to:
  /// **'Обновления yt-dlp'**
  String get setPolicyYtdlp;

  /// No description provided for @setPolicyYtdlpHint.
  ///
  /// In ru, this message translates to:
  /// **'Сайты часто меняются — лучше обновлять автоматически'**
  String get setPolicyYtdlpHint;

  /// No description provided for @setPolicyOther.
  ///
  /// In ru, this message translates to:
  /// **'Обновления остальных компонентов'**
  String get setPolicyOther;

  /// No description provided for @setPolicyHelp.
  ///
  /// In ru, this message translates to:
  /// **'«Автоматически» — проверить и установить при запуске; «Спрашивать» — показать значок обновления в «Компонентах»; «Никогда» — не проверять. Предыдущая версия сохраняется, к ней можно откатиться. По умолчанию: yt-dlp — автоматически, остальное — спрашивать.'**
  String get setPolicyHelp;

  /// No description provided for @policyAuto.
  ///
  /// In ru, this message translates to:
  /// **'Автоматически'**
  String get policyAuto;

  /// No description provided for @policyAsk.
  ///
  /// In ru, this message translates to:
  /// **'Спрашивать'**
  String get policyAsk;

  /// No description provided for @policyNever.
  ///
  /// In ru, this message translates to:
  /// **'Никогда'**
  String get policyNever;

  /// No description provided for @setKeepVersions.
  ///
  /// In ru, this message translates to:
  /// **'Хранить предыдущие версии'**
  String get setKeepVersions;

  /// No description provided for @setKeepVersionsHint.
  ///
  /// In ru, this message translates to:
  /// **'Сколько старых версий оставить для отката'**
  String get setKeepVersionsHint;

  /// No description provided for @setKeepVersionsHelp.
  ///
  /// In ru, this message translates to:
  /// **'Каждая версия ffmpeg занимает 100–250 МБ. 0 — откат будет невозможен. По умолчанию: 2.'**
  String get setKeepVersionsHelp;

  /// No description provided for @zoneLessDisk.
  ///
  /// In ru, this message translates to:
  /// **'меньше места'**
  String get zoneLessDisk;

  /// No description provided for @zoneMoreRollback.
  ///
  /// In ru, this message translates to:
  /// **'больше откатов'**
  String get zoneMoreRollback;

  /// No description provided for @setNotify.
  ///
  /// In ru, this message translates to:
  /// **'Уведомлять о завершении'**
  String get setNotify;

  /// No description provided for @setNotifyHint.
  ///
  /// In ru, this message translates to:
  /// **'Системное уведомление, когда задача готова'**
  String get setNotifyHint;

  /// No description provided for @setShowCommand.
  ///
  /// In ru, this message translates to:
  /// **'Показывать команду перед запуском'**
  String get setShowCommand;

  /// No description provided for @setShowCommandHint.
  ///
  /// In ru, this message translates to:
  /// **'Можно проверить и отредактировать команду ffmpeg'**
  String get setShowCommandHint;

  /// No description provided for @setShowCommandHelp.
  ///
  /// In ru, this message translates to:
  /// **'Перед добавлением в очередь откроется готовая команда ffmpeg: её можно скопировать, изменить и запустить. Кнопка «Показать команду» доступна у каждой задачи в любом случае. По умолчанию: выключено.'**
  String get setShowCommandHelp;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
