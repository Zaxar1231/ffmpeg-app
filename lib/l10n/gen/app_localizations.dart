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

  /// No description provided for @errLoudnessMeasure.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось измерить громкость: в файле тишина или нет звука.'**
  String get errLoudnessMeasure;

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

  /// No description provided for @back.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get back;

  /// No description provided for @change.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get change;

  /// No description provided for @apply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get apply;

  /// No description provided for @rename.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать'**
  String get rename;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @none.
  ///
  /// In ru, this message translates to:
  /// **'нет'**
  String get none;

  /// No description provided for @keepOriginal.
  ///
  /// In ru, this message translates to:
  /// **'Как в исходнике'**
  String get keepOriginal;

  /// No description provided for @stereo.
  ///
  /// In ru, this message translates to:
  /// **'Стерео'**
  String get stereo;

  /// No description provided for @mono.
  ///
  /// In ru, this message translates to:
  /// **'Моно'**
  String get mono;

  /// No description provided for @toEnd.
  ///
  /// In ru, this message translates to:
  /// **'до конца'**
  String get toEnd;

  /// No description provided for @addToQueue.
  ///
  /// In ru, this message translates to:
  /// **'В очередь'**
  String get addToQueue;

  /// No description provided for @runNow.
  ///
  /// In ru, this message translates to:
  /// **'Запустить'**
  String get runNow;

  /// No description provided for @otherFile.
  ///
  /// In ru, this message translates to:
  /// **'Другой файл'**
  String get otherFile;

  /// No description provided for @saveTo.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить в: {path}'**
  String saveTo(String path);

  /// No description provided for @chooseInputTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выберите файл'**
  String get chooseInputTitle;

  /// No description provided for @commandEditHint.
  ///
  /// In ru, this message translates to:
  /// **'Можно изменить аргументы перед запуском (путь к ffmpeg подставится сам).'**
  String get commandEditHint;

  /// No description provided for @commandParseError.
  ///
  /// In ru, this message translates to:
  /// **'Незакрытая кавычка в команде'**
  String get commandParseError;

  /// No description provided for @runCommand.
  ///
  /// In ru, this message translates to:
  /// **'Запустить'**
  String get runCommand;

  /// No description provided for @stepLabel.
  ///
  /// In ru, this message translates to:
  /// **'шаг {step}'**
  String stepLabel(String step);

  /// No description provided for @secondsShort.
  ///
  /// In ru, this message translates to:
  /// **'{value} с'**
  String secondsShort(String value);

  /// No description provided for @estimateSize.
  ///
  /// In ru, this message translates to:
  /// **'≈ {size}'**
  String estimateSize(String size);

  /// No description provided for @estimateAtMost.
  ///
  /// In ru, this message translates to:
  /// **'не больше {size}'**
  String estimateAtMost(String size);

  /// No description provided for @estimateDependsOnContent.
  ///
  /// In ru, this message translates to:
  /// **'Размер зависит от содержимого'**
  String get estimateDependsOnContent;

  /// No description provided for @encoderLabel.
  ///
  /// In ru, this message translates to:
  /// **'кодировщик {name}'**
  String encoderLabel(String name);

  /// No description provided for @issueNoEncoder.
  ///
  /// In ru, this message translates to:
  /// **'В установленной сборке ffmpeg нет кодировщика для этого кодека. Выберите другой кодек или установите full-сборку.'**
  String get issueNoEncoder;

  /// No description provided for @issueVideoContainer.
  ///
  /// In ru, this message translates to:
  /// **'Этот контейнер не поддерживает выбранный видеокодек. Выберите другой кодек или MKV.'**
  String get issueVideoContainer;

  /// No description provided for @issueAudioContainer.
  ///
  /// In ru, this message translates to:
  /// **'Этот контейнер не поддерживает выбранный аудиокодек. Выберите другой кодек или MKV.'**
  String get issueAudioContainer;

  /// No description provided for @issueCopyContainer.
  ///
  /// In ru, this message translates to:
  /// **'Исходный кодек нельзя скопировать в этот контейнер без перекодирования. Попробуйте MKV.'**
  String get issueCopyContainer;

  /// No description provided for @issueDurationUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Длительность файла неизвестна, поэтому нельзя рассчитать размер или обрезку.'**
  String get issueDurationUnknown;

  /// No description provided for @issueTargetTooSmall.
  ///
  /// In ru, this message translates to:
  /// **'Слишком маленький размер для такой длительности: на видео остаётся меньше 50 кбит/с. Увеличьте размер или уменьшите длительность.'**
  String get issueTargetTooSmall;

  /// No description provided for @issueNoTenBit.
  ///
  /// In ru, this message translates to:
  /// **'Этот кодировщик не умеет 10 бит — будет 8 бит.'**
  String get issueNoTenBit;

  /// No description provided for @issueNoAudio.
  ///
  /// In ru, this message translates to:
  /// **'В файле нет звуковой дорожки.'**
  String get issueNoAudio;

  /// No description provided for @issueNoVideo.
  ///
  /// In ru, this message translates to:
  /// **'В файле нет видео.'**
  String get issueNoVideo;

  /// No description provided for @issueChooseAudio.
  ///
  /// In ru, this message translates to:
  /// **'Выберите файл со звуком.'**
  String get issueChooseAudio;

  /// No description provided for @warnHdrSource.
  ///
  /// In ru, this message translates to:
  /// **'Исходник в HDR. Без 10 бит и тонмаппинга цвета будут блёклыми; полноценное HDR → SDR — в следующем этапе.'**
  String get warnHdrSource;

  /// No description provided for @warnLongGif.
  ///
  /// In ru, this message translates to:
  /// **'GIF длиннее 20 секунд получится очень большим. Лучше WebP или видео.'**
  String get warnLongGif;

  /// No description provided for @groupFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат'**
  String get groupFormat;

  /// No description provided for @groupVideo.
  ///
  /// In ru, this message translates to:
  /// **'Видео'**
  String get groupVideo;

  /// No description provided for @groupAudio.
  ///
  /// In ru, this message translates to:
  /// **'Звук'**
  String get groupAudio;

  /// No description provided for @groupOther.
  ///
  /// In ru, this message translates to:
  /// **'Прочее'**
  String get groupOther;

  /// No description provided for @groupTrim.
  ///
  /// In ru, this message translates to:
  /// **'Фрагмент'**
  String get groupTrim;

  /// No description provided for @groupLoudness.
  ///
  /// In ru, this message translates to:
  /// **'Громкость'**
  String get groupLoudness;

  /// No description provided for @groupAnimation.
  ///
  /// In ru, this message translates to:
  /// **'Анимация'**
  String get groupAnimation;

  /// No description provided for @groupDownloadQuality.
  ///
  /// In ru, this message translates to:
  /// **'Качество'**
  String get groupDownloadQuality;

  /// No description provided for @groupDownloadExtras.
  ///
  /// In ru, this message translates to:
  /// **'Дополнительно'**
  String get groupDownloadExtras;

  /// No description provided for @presetsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пресеты'**
  String get presetsTitle;

  /// No description provided for @savePreset.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить как пресет'**
  String get savePreset;

  /// No description provided for @presetNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название пресета'**
  String get presetNameLabel;

  /// No description provided for @builtinPresets.
  ///
  /// In ru, this message translates to:
  /// **'Встроенные'**
  String get builtinPresets;

  /// No description provided for @userPresets.
  ///
  /// In ru, this message translates to:
  /// **'Мои пресеты'**
  String get userPresets;

  /// No description provided for @userPresetsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока пусто. В «Конвертации» настройте параметры и нажмите «Сохранить как пресет».'**
  String get userPresetsEmpty;

  /// No description provided for @importPresets.
  ///
  /// In ru, this message translates to:
  /// **'Импорт'**
  String get importPresets;

  /// No description provided for @exportPresets.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт'**
  String get exportPresets;

  /// No description provided for @presetsImported.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Импортирован {count} пресет} few{Импортировано {count} пресета} many{Импортировано {count} пресетов} other{Импортировано {count} пресета}}'**
  String presetsImported(int count);

  /// No description provided for @presetsExported.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Экспортирован {count} пресет} few{Экспортировано {count} пресета} many{Экспортировано {count} пресетов} other{Экспортировано {count} пресета}}'**
  String presetsExported(int count);

  /// No description provided for @presetsImportFailed.
  ///
  /// In ru, this message translates to:
  /// **'Это не файл пресетов Kadra.'**
  String get presetsImportFailed;

  /// No description provided for @presetTelegram.
  ///
  /// In ru, this message translates to:
  /// **'Для Telegram'**
  String get presetTelegram;

  /// No description provided for @presetTelegramDesc.
  ///
  /// In ru, this message translates to:
  /// **'H.264 до 1080p, быстрый старт — проигрывается прямо в чате.'**
  String get presetTelegramDesc;

  /// No description provided for @presetYoutube.
  ///
  /// In ru, this message translates to:
  /// **'Для YouTube'**
  String get presetYoutube;

  /// No description provided for @presetYoutubeDesc.
  ///
  /// In ru, this message translates to:
  /// **'Высокое качество (CRF 18), AAC 320 кбит/с 48 кГц — YouTube всё равно перекодирует.'**
  String get presetYoutubeDesc;

  /// No description provided for @presetDiscord.
  ///
  /// In ru, this message translates to:
  /// **'Для Discord (до 10 МБ)'**
  String get presetDiscord;

  /// No description provided for @presetDiscordDesc.
  ///
  /// In ru, this message translates to:
  /// **'Два прохода под 9,5 МБ, до 720p — влезает в бесплатный лимит.'**
  String get presetDiscordDesc;

  /// No description provided for @presetEditProres.
  ///
  /// In ru, this message translates to:
  /// **'Для монтажа (ProRes)'**
  String get presetEditProres;

  /// No description provided for @presetEditProresDesc.
  ///
  /// In ru, this message translates to:
  /// **'ProRes 422 HQ + PCM: легко монтировать, файлы большие.'**
  String get presetEditProresDesc;

  /// No description provided for @presetEditDnxhr.
  ///
  /// In ru, this message translates to:
  /// **'Для монтажа (DNxHR)'**
  String get presetEditDnxhr;

  /// No description provided for @presetEditDnxhrDesc.
  ///
  /// In ru, this message translates to:
  /// **'DNxHR HQ + PCM для Avid и DaVinci Resolve.'**
  String get presetEditDnxhrDesc;

  /// No description provided for @presetArchive.
  ///
  /// In ru, this message translates to:
  /// **'Архив без потерь'**
  String get presetArchive;

  /// No description provided for @presetArchiveDesc.
  ///
  /// In ru, this message translates to:
  /// **'FFV1 + FLAC в MKV: бит в бит, без потери качества.'**
  String get presetArchiveDesc;

  /// No description provided for @presetMaxCompression.
  ///
  /// In ru, this message translates to:
  /// **'Максимальное сжатие'**
  String get presetMaxCompression;

  /// No description provided for @presetMaxCompressionDesc.
  ///
  /// In ru, this message translates to:
  /// **'AV1 10 бит + Opus: минимальный размер при хорошем качестве, но кодирует долго.'**
  String get presetMaxCompressionDesc;

  /// No description provided for @presetCompress.
  ///
  /// In ru, this message translates to:
  /// **'Просто сжать'**
  String get presetCompress;

  /// No description provided for @presetCompressDesc.
  ///
  /// In ru, this message translates to:
  /// **'H.264, качество чуть ниже, до 1080p — обычно в 2–5 раз меньше.'**
  String get presetCompressDesc;

  /// No description provided for @codecCopy.
  ///
  /// In ru, this message translates to:
  /// **'Копировать (без перекодирования)'**
  String get codecCopy;

  /// No description provided for @codecNoVideo.
  ///
  /// In ru, this message translates to:
  /// **'Без видео'**
  String get codecNoVideo;

  /// No description provided for @codecNoAudio.
  ///
  /// In ru, this message translates to:
  /// **'Без звука'**
  String get codecNoAudio;

  /// No description provided for @codecFfv1.
  ///
  /// In ru, this message translates to:
  /// **'FFV1 (без потерь)'**
  String get codecFfv1;

  /// No description provided for @codecFlac.
  ///
  /// In ru, this message translates to:
  /// **'FLAC (без потерь)'**
  String get codecFlac;

  /// No description provided for @codecAlac.
  ///
  /// In ru, this message translates to:
  /// **'ALAC (без потерь)'**
  String get codecAlac;

  /// No description provided for @speedFastest.
  ///
  /// In ru, this message translates to:
  /// **'очень быстро'**
  String get speedFastest;

  /// No description provided for @speedFast.
  ///
  /// In ru, this message translates to:
  /// **'быстро'**
  String get speedFast;

  /// No description provided for @speedMedium.
  ///
  /// In ru, this message translates to:
  /// **'средне'**
  String get speedMedium;

  /// No description provided for @speedSlow.
  ///
  /// In ru, this message translates to:
  /// **'медленно'**
  String get speedSlow;

  /// No description provided for @speedSlowest.
  ///
  /// In ru, this message translates to:
  /// **'очень медленно'**
  String get speedSlowest;

  /// No description provided for @rateQuality.
  ///
  /// In ru, this message translates to:
  /// **'Качество'**
  String get rateQuality;

  /// No description provided for @rateBitrate.
  ///
  /// In ru, this message translates to:
  /// **'Битрейт'**
  String get rateBitrate;

  /// No description provided for @rateCbr.
  ///
  /// In ru, this message translates to:
  /// **'Постоянный'**
  String get rateCbr;

  /// No description provided for @rateTargetSize.
  ///
  /// In ru, this message translates to:
  /// **'Размер файла'**
  String get rateTargetSize;

  /// No description provided for @zoneBetterQuality.
  ///
  /// In ru, this message translates to:
  /// **'лучше качество'**
  String get zoneBetterQuality;

  /// No description provided for @zoneSmallerFile.
  ///
  /// In ru, this message translates to:
  /// **'меньше размер'**
  String get zoneSmallerFile;

  /// No description provided for @zoneSmoother.
  ///
  /// In ru, this message translates to:
  /// **'плавнее'**
  String get zoneSmoother;

  /// No description provided for @pContainer.
  ///
  /// In ru, this message translates to:
  /// **'Контейнер (формат файла)'**
  String get pContainer;

  /// No description provided for @pContainerHint.
  ///
  /// In ru, this message translates to:
  /// **'Во что «упаковать» видео и звук'**
  String get pContainerHint;

  /// No description provided for @pContainerHelp.
  ///
  /// In ru, this message translates to:
  /// **'Контейнер — это «коробка», в которой лежат дорожки. MP4 открывается везде (телефоны, браузеры, мессенджеры). MKV принимает почти любые кодеки и субтитры — хорош для архива. MOV — для Apple и монтажа. WebM — для сайтов (VP9/AV1 + Opus). Для одного звука: MP3, M4A, Opus, FLAC, WAV. По умолчанию: MP4.'**
  String get pContainerHelp;

  /// No description provided for @pVideoCodec.
  ///
  /// In ru, this message translates to:
  /// **'Видеокодек'**
  String get pVideoCodec;

  /// No description provided for @pVideoCodecHint.
  ///
  /// In ru, this message translates to:
  /// **'Чем сжимать картинку'**
  String get pVideoCodecHint;

  /// No description provided for @pVideoCodecHelp.
  ///
  /// In ru, this message translates to:
  /// **'H.264 — максимальная совместимость. H.265 — на 30–50% меньше при том же качестве, но не везде играет. AV1 — ещё меньше, кодирует медленнее (быстро на новых видеокартах). VP9 — для WebM. ProRes и DNxHR — для монтажа (большие файлы). FFV1 — без потерь. «Копировать» — мгновенно, без потери качества, если формат подходит. По умолчанию: H.264.'**
  String get pVideoCodecHelp;

  /// No description provided for @pAudioCodec.
  ///
  /// In ru, this message translates to:
  /// **'Аудиокодек'**
  String get pAudioCodec;

  /// No description provided for @pAudioCodecHint.
  ///
  /// In ru, this message translates to:
  /// **'Чем сжимать звук'**
  String get pAudioCodecHint;

  /// No description provided for @pHardware.
  ///
  /// In ru, this message translates to:
  /// **'Аппаратное кодирование'**
  String get pHardware;

  /// No description provided for @pHardwareOn.
  ///
  /// In ru, this message translates to:
  /// **'Используется видеокарта: {name}'**
  String pHardwareOn(String name);

  /// No description provided for @pHardwareOff.
  ///
  /// In ru, this message translates to:
  /// **'Кодирует процессор: {name}'**
  String pHardwareOff(String name);

  /// No description provided for @pHardwareHelp.
  ///
  /// In ru, this message translates to:
  /// **'Видеокарта (NVENC, Quick Sync, AMF, VAAPI) кодирует в 5–20 раз быстрее процессора, но при том же размере файла качество немного ниже. Для быстрых задач — включите, для архива и минимального размера — выключите. Если подходящей видеокарты нет, используется процессор. По умолчанию: включено.'**
  String get pHardwareHelp;

  /// No description provided for @pEncoder.
  ///
  /// In ru, this message translates to:
  /// **'Кодировщик'**
  String get pEncoder;

  /// No description provided for @pEncoderHint.
  ///
  /// In ru, this message translates to:
  /// **'Конкретная реализация кодека из сборки ffmpeg'**
  String get pEncoderHint;

  /// No description provided for @pRateMode.
  ///
  /// In ru, this message translates to:
  /// **'Режим'**
  String get pRateMode;

  /// No description provided for @pRateModeHint.
  ///
  /// In ru, this message translates to:
  /// **'Как управлять размером и качеством'**
  String get pRateModeHint;

  /// No description provided for @pRateModeHelp.
  ///
  /// In ru, this message translates to:
  /// **'«Качество» (CRF/CQ) — лучший выбор почти всегда: постоянное качество, размер подстраивается под сложность сцены. «Битрейт» — средний поток в кбит/с, предсказуемый размер. «Постоянный» — одинаковый поток для стриминга и старых плееров. «Размер файла» — укажите, сколько мегабайт должно получиться (например, лимит мессенджера), битрейт рассчитается сам, по возможности в два прохода. По умолчанию: «Качество».'**
  String get pRateModeHelp;

  /// No description provided for @pQuality.
  ///
  /// In ru, this message translates to:
  /// **'Качество ({scale})'**
  String pQuality(String scale);

  /// No description provided for @pQualityHint.
  ///
  /// In ru, this message translates to:
  /// **'Меньше число — лучше качество и больше файл'**
  String get pQualityHint;

  /// No description provided for @pQualityHelp.
  ///
  /// In ru, this message translates to:
  /// **'Это «постоянное качество» кодировщика: каждая сцена кодируется так, чтобы выглядеть одинаково хорошо. Шаг в 6 единиц примерно вдвое меняет размер. Для x264: 18 — визуально без потерь, 23 — стандарт, 28 — заметно хуже. У AV1/VP9 шкала до 63. Значение по умолчанию для этого кодировщика: {value}.'**
  String pQualityHelp(int value);

  /// No description provided for @pVideoBitrate.
  ///
  /// In ru, this message translates to:
  /// **'Битрейт видео'**
  String get pVideoBitrate;

  /// No description provided for @pVideoBitrateHint.
  ///
  /// In ru, this message translates to:
  /// **'Сколько килобит в секунду на видео'**
  String get pVideoBitrateHint;

  /// No description provided for @pVideoBitrateHelp.
  ///
  /// In ru, this message translates to:
  /// **'Ориентиры для H.264: 1080p — 4000–8000, 720p — 2500–5000, 480p — 1000–2000 кбит/с. H.265/AV1 нужно примерно на 30–50% меньше.'**
  String get pVideoBitrateHelp;

  /// No description provided for @pTargetSize.
  ///
  /// In ru, this message translates to:
  /// **'Размер файла'**
  String get pTargetSize;

  /// No description provided for @pTargetSizeHint.
  ///
  /// In ru, this message translates to:
  /// **'Итоговый файл будет не больше этого'**
  String get pTargetSizeHint;

  /// No description provided for @pTargetSizeHelp.
  ///
  /// In ru, this message translates to:
  /// **'Битрейт рассчитывается из длительности: (размер × 8) / секунды − звук, с запасом 3% на контейнер. Слишком маленький размер для длинного видео даст «мыло» — уменьшите разрешение. Discord: 10 МБ (ставьте 9,5), Telegram для ботов: 50 МБ.'**
  String get pTargetSizeHelp;

  /// No description provided for @pTwoPass.
  ///
  /// In ru, this message translates to:
  /// **'Два прохода'**
  String get pTwoPass;

  /// No description provided for @pTwoPassHint.
  ///
  /// In ru, this message translates to:
  /// **'Точнее попадает в размер, но вдвое дольше'**
  String get pTwoPassHint;

  /// No description provided for @pTwoPassHelp.
  ///
  /// In ru, this message translates to:
  /// **'Первый проход анализирует видео, второй распределяет биты: сложным сценам больше, простым меньше. Даёт лучшее качество при заданном размере. Для режима «Качество» не нужен. По умолчанию: включено.'**
  String get pTwoPassHelp;

  /// No description provided for @pSpeed.
  ///
  /// In ru, this message translates to:
  /// **'Скорость кодирования'**
  String get pSpeed;

  /// No description provided for @pSpeedHint.
  ///
  /// In ru, this message translates to:
  /// **'Медленнее — меньше файл при том же качестве'**
  String get pSpeedHint;

  /// No description provided for @pSpeedHelp.
  ///
  /// In ru, this message translates to:
  /// **'Пресет скорости кодировщика (x264: veryfast…veryslow, NVENC: p1…p7, SVT-AV1: 12…4). Качество задаётся отдельно; медленный пресет лишь лучше сжимает. «Средне» — разумный баланс; «медленно» даёт −5–10% размера за ×2–3 времени. По умолчанию: средне.'**
  String get pSpeedHelp;

  /// No description provided for @pResolution.
  ///
  /// In ru, this message translates to:
  /// **'Разрешение'**
  String get pResolution;

  /// No description provided for @pResolutionHint.
  ///
  /// In ru, this message translates to:
  /// **'Уменьшить до этой высоты (не увеличивает)'**
  String get pResolutionHint;

  /// No description provided for @pResolutionHelp.
  ///
  /// In ru, this message translates to:
  /// **'Пропорции сохраняются, ширина округляется до чётной. Уменьшение разрешения — самый эффективный способ сжать: 1080p → 720p уменьшает файл примерно вдвое. По умолчанию: как в исходнике.'**
  String get pResolutionHelp;

  /// No description provided for @pFps.
  ///
  /// In ru, this message translates to:
  /// **'Частота кадров'**
  String get pFps;

  /// No description provided for @pFpsHint.
  ///
  /// In ru, this message translates to:
  /// **'Кадров в секунду'**
  String get pFpsHint;

  /// No description provided for @pTenBit.
  ///
  /// In ru, this message translates to:
  /// **'10 бит'**
  String get pTenBit;

  /// No description provided for @pTenBitHint.
  ///
  /// In ru, this message translates to:
  /// **'Меньше полос на градиентах, нужно для HDR'**
  String get pTenBitHint;

  /// No description provided for @pTenBitHelp.
  ///
  /// In ru, this message translates to:
  /// **'10 бит на канал убирают «ступеньки» на небе и в тенях и немного улучшают сжатие у H.265/AV1. Старые устройства и некоторые браузеры H.264 10 бит не воспроизводят. По умолчанию: выключено.'**
  String get pTenBitHelp;

  /// No description provided for @pProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get pProfile;

  /// No description provided for @pProfileHint.
  ///
  /// In ru, this message translates to:
  /// **'Ограничения совместимости кодека'**
  String get pProfileHint;

  /// No description provided for @pIntermediateProfileHint.
  ///
  /// In ru, this message translates to:
  /// **'Качество и размер монтажного формата'**
  String get pIntermediateProfileHint;

  /// No description provided for @pIntermediateProfileHelp.
  ///
  /// In ru, this message translates to:
  /// **'ProRes: proxy < lt < standard < hq < 4444 < 4444xq. DNxHR: lb < sq < hq < hqx (10 бит) < 444. Для монтажа обычно хватает HQ. По умолчанию: HQ.'**
  String get pIntermediateProfileHelp;

  /// No description provided for @pTune.
  ///
  /// In ru, this message translates to:
  /// **'Настройка под содержимое'**
  String get pTune;

  /// No description provided for @pTuneHint.
  ///
  /// In ru, this message translates to:
  /// **'Оптимизация под тип видео'**
  String get pTuneHint;

  /// No description provided for @pTuneHelp.
  ///
  /// In ru, this message translates to:
  /// **'film — живое видео, animation — мультфильмы, grain — сохранить зерно плёнки, stillimage — слайд-шоу, zerolatency — стриминг с минимальной задержкой. По умолчанию: нет.'**
  String get pTuneHelp;

  /// No description provided for @pKeyint.
  ///
  /// In ru, this message translates to:
  /// **'Интервал ключевых кадров'**
  String get pKeyint;

  /// No description provided for @pKeyintHint.
  ///
  /// In ru, this message translates to:
  /// **'Как часто можно начать воспроизведение с любого места'**
  String get pKeyintHint;

  /// No description provided for @pKeyintHelp.
  ///
  /// In ru, this message translates to:
  /// **'Чем чаще ключевые кадры, тем быстрее перемотка и точнее быстрая обрезка, но файл больше. Для YouTube и стриминга рекомендуют 2 секунды. По умолчанию: авто (решает кодировщик).'**
  String get pKeyintHelp;

  /// No description provided for @pAudioBitrate.
  ///
  /// In ru, this message translates to:
  /// **'Битрейт звука'**
  String get pAudioBitrate;

  /// No description provided for @pAudioBitrateHint.
  ///
  /// In ru, this message translates to:
  /// **'Больше — лучше звук и больше файл'**
  String get pAudioBitrateHint;

  /// No description provided for @pAudioBitrateHelp.
  ///
  /// In ru, this message translates to:
  /// **'Ориентиры: AAC 128 — нормально для речи и музыки, 192–256 — для музыки, 320 — максимум. Opus звучит хорошо уже на 96. MP3 320 — предел формата. По умолчанию: зависит от кодека.'**
  String get pAudioBitrateHelp;

  /// No description provided for @pChannels.
  ///
  /// In ru, this message translates to:
  /// **'Каналы'**
  String get pChannels;

  /// No description provided for @pChannelsHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, свести 5.1 в стерео'**
  String get pChannelsHint;

  /// No description provided for @pSampleRate.
  ///
  /// In ru, this message translates to:
  /// **'Частота дискретизации'**
  String get pSampleRate;

  /// No description provided for @pSampleRateHint.
  ///
  /// In ru, this message translates to:
  /// **'48 кГц — видео, 44,1 кГц — музыка'**
  String get pSampleRateHint;

  /// No description provided for @pFaststart.
  ///
  /// In ru, this message translates to:
  /// **'Быстрый старт (faststart)'**
  String get pFaststart;

  /// No description provided for @pFaststartHint.
  ///
  /// In ru, this message translates to:
  /// **'Видео начинает играть в браузере до полной загрузки'**
  String get pFaststartHint;

  /// No description provided for @pFaststartHelp.
  ///
  /// In ru, this message translates to:
  /// **'Переносит индекс (moov) в начало MP4/MOV. Нужен для сайтов и мессенджеров, ничего не стоит. По умолчанию: включено.'**
  String get pFaststartHelp;

  /// No description provided for @pKeepSubs.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить субтитры'**
  String get pKeepSubs;

  /// No description provided for @pKeepSubsHint.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать дорожки субтитров как есть'**
  String get pKeepSubsHint;

  /// No description provided for @pKeepMetadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить метаданные'**
  String get pKeepMetadata;

  /// No description provided for @pKeepMetadataHint.
  ///
  /// In ru, this message translates to:
  /// **'Теги, главы, дата съёмки. Выключите, чтобы удалить'**
  String get pKeepMetadataHint;

  /// No description provided for @pTrimMode.
  ///
  /// In ru, this message translates to:
  /// **'Способ обрезки'**
  String get pTrimMode;

  /// No description provided for @trimFast.
  ///
  /// In ru, this message translates to:
  /// **'Быстро'**
  String get trimFast;

  /// No description provided for @trimPrecise.
  ///
  /// In ru, this message translates to:
  /// **'Точно до кадра'**
  String get trimPrecise;

  /// No description provided for @trimFastHint.
  ///
  /// In ru, this message translates to:
  /// **'Мгновенно, без потери качества; начало — по ближайшему ключевому кадру'**
  String get trimFastHint;

  /// No description provided for @trimPreciseHint.
  ///
  /// In ru, this message translates to:
  /// **'Перекодирует фрагмент: точные границы, но дольше'**
  String get trimPreciseHint;

  /// No description provided for @pTrimModeHelp.
  ///
  /// In ru, this message translates to:
  /// **'Видео хранится группами кадров, которые начинаются с ключевого кадра. Быстрая обрезка копирует данные как есть, поэтому может начаться чуть раньше выбранной точки — до ближайшего ключевого кадра (обычно 0–5 секунд). Точная перекодирует фрагмент и режет ровно по кадру; качество почти не страдает.'**
  String get pTrimModeHelp;

  /// No description provided for @pStart.
  ///
  /// In ru, this message translates to:
  /// **'Начало'**
  String get pStart;

  /// No description provided for @pStartHint.
  ///
  /// In ru, this message translates to:
  /// **'ЧЧ:ММ:СС.мс или секунды'**
  String get pStartHint;

  /// No description provided for @pEnd.
  ///
  /// In ru, this message translates to:
  /// **'Конец'**
  String get pEnd;

  /// No description provided for @pEndHint.
  ///
  /// In ru, this message translates to:
  /// **'Длительность файла: {total}'**
  String pEndHint(String total);

  /// No description provided for @keyframeStartHint.
  ///
  /// In ru, this message translates to:
  /// **'Фактически начнётся с {time} (ключевой кадр)'**
  String keyframeStartHint(String time);

  /// No description provided for @setStartHere.
  ///
  /// In ru, this message translates to:
  /// **'Начало = {time}'**
  String setStartHere(String time);

  /// No description provided for @setEndHere.
  ///
  /// In ru, this message translates to:
  /// **'Конец = {time}'**
  String setEndHere(String time);

  /// No description provided for @trimLength.
  ///
  /// In ru, this message translates to:
  /// **'Фрагмент: {time}'**
  String trimLength(String time);

  /// No description provided for @pTrack.
  ///
  /// In ru, this message translates to:
  /// **'Дорожка'**
  String get pTrack;

  /// No description provided for @pTrackHint.
  ///
  /// In ru, this message translates to:
  /// **'Какую звуковую дорожку извлечь'**
  String get pTrackHint;

  /// No description provided for @pExtractFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат'**
  String get pExtractFormat;

  /// No description provided for @pExtractFormatHint.
  ///
  /// In ru, this message translates to:
  /// **'Перекодировать в выбранный формат'**
  String get pExtractFormatHint;

  /// No description provided for @pExtractFormatHelp.
  ///
  /// In ru, this message translates to:
  /// **'«Как есть» копирует звук без изменений — мгновенно и без потерь, формат файла подбирается под кодек. Выберите MP3/AAC/Opus, если нужен конкретный формат для плеера, FLAC/WAV — для обработки без потерь.'**
  String get pExtractFormatHelp;

  /// No description provided for @extractAsIs.
  ///
  /// In ru, this message translates to:
  /// **'Как есть (без перекодирования)'**
  String get extractAsIs;

  /// No description provided for @extractCopyHint.
  ///
  /// In ru, this message translates to:
  /// **'Будет файл .{ext} без потери качества'**
  String extractCopyHint(String ext);

  /// No description provided for @pTrackMode.
  ///
  /// In ru, this message translates to:
  /// **'Что сделать'**
  String get pTrackMode;

  /// No description provided for @trackReplace.
  ///
  /// In ru, this message translates to:
  /// **'Заменить'**
  String get trackReplace;

  /// No description provided for @trackAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get trackAdd;

  /// No description provided for @trackRemove.
  ///
  /// In ru, this message translates to:
  /// **'Удалить звук'**
  String get trackRemove;

  /// No description provided for @trackReplaceHint.
  ///
  /// In ru, this message translates to:
  /// **'Убрать старый звук и поставить новый'**
  String get trackReplaceHint;

  /// No description provided for @trackAddHint.
  ///
  /// In ru, this message translates to:
  /// **'Оставить старые дорожки и добавить ещё одну (например, перевод)'**
  String get trackAddHint;

  /// No description provided for @trackRemoveHint.
  ///
  /// In ru, this message translates to:
  /// **'Сделать видео без звука'**
  String get trackRemoveHint;

  /// No description provided for @pAudioFile.
  ///
  /// In ru, this message translates to:
  /// **'Файл со звуком'**
  String get pAudioFile;

  /// No description provided for @pAudioFileHint.
  ///
  /// In ru, this message translates to:
  /// **'Можно взять звук из любого аудио- или видеофайла'**
  String get pAudioFileHint;

  /// No description provided for @pShortest.
  ///
  /// In ru, this message translates to:
  /// **'По самой короткой дорожке'**
  String get pShortest;

  /// No description provided for @pShortestHint.
  ///
  /// In ru, this message translates to:
  /// **'Обрезать результат, когда кончится видео или звук'**
  String get pShortestHint;

  /// No description provided for @pLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык дорожки'**
  String get pLanguage;

  /// No description provided for @pLanguageHint.
  ///
  /// In ru, this message translates to:
  /// **'Плееры покажут его при выборе дорожки'**
  String get pLanguageHint;

  /// No description provided for @losslessVideoTag.
  ///
  /// In ru, this message translates to:
  /// **'видео без перекодирования'**
  String get losslessVideoTag;

  /// No description provided for @videoCopiedNote.
  ///
  /// In ru, this message translates to:
  /// **'Видео копируется — быстро и без потери качества'**
  String get videoCopiedNote;

  /// No description provided for @pLoudTarget.
  ///
  /// In ru, this message translates to:
  /// **'Целевая громкость'**
  String get pLoudTarget;

  /// No description provided for @pLoudTargetHint.
  ///
  /// In ru, this message translates to:
  /// **'{lufs} LUFS, пики не выше {tp} dBTP'**
  String pLoudTargetHint(String lufs, String tp);

  /// No description provided for @pLoudTargetHelp.
  ///
  /// In ru, this message translates to:
  /// **'LUFS — воспринимаемая громкость. Площадки сами приглушают слишком громкое, поэтому лучше сразу попасть в их цель: YouTube и Spotify −14, подкасты (Apple) −16, ТВ по EBU R128 −23. True Peak ограничивает пики, чтобы не было искажений после сжатия в MP3/AAC.'**
  String get pLoudTargetHelp;

  /// No description provided for @loudStreaming.
  ///
  /// In ru, this message translates to:
  /// **'YouTube, Spotify'**
  String get loudStreaming;

  /// No description provided for @loudPodcast.
  ///
  /// In ru, this message translates to:
  /// **'Подкаст'**
  String get loudPodcast;

  /// No description provided for @loudBroadcast.
  ///
  /// In ru, this message translates to:
  /// **'ТВ (EBU R128)'**
  String get loudBroadcast;

  /// No description provided for @loudApple.
  ///
  /// In ru, this message translates to:
  /// **'Apple Music'**
  String get loudApple;

  /// No description provided for @pTwoPassLoud.
  ///
  /// In ru, this message translates to:
  /// **'Двухпроходная нормализация'**
  String get pTwoPassLoud;

  /// No description provided for @pTwoPassLoudOn.
  ///
  /// In ru, this message translates to:
  /// **'Сначала измерить, затем точно привести громкость'**
  String get pTwoPassLoudOn;

  /// No description provided for @pTwoPassLoudOff.
  ///
  /// In ru, this message translates to:
  /// **'Один проход: быстрее, но с динамической подстройкой'**
  String get pTwoPassLoudOff;

  /// No description provided for @pTwoPassLoudHelp.
  ///
  /// In ru, this message translates to:
  /// **'Первый проход измеряет громкость всего файла, второй применяет одно и то же усиление ко всему — динамика не меняется, результат точно в цели. Однопроходный режим подстраивает громкость на лету и может «качать» звук. По умолчанию: два прохода.'**
  String get pTwoPassLoudHelp;

  /// No description provided for @normalizeNote.
  ///
  /// In ru, this message translates to:
  /// **'Звук будет перекодирован ({codec}), видео скопировано'**
  String normalizeNote(String codec);

  /// No description provided for @pAnimFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат'**
  String get pAnimFormat;

  /// No description provided for @pAnimFormatHint.
  ///
  /// In ru, this message translates to:
  /// **'GIF работает везде, WebP и APNG — качественнее и меньше'**
  String get pAnimFormatHint;

  /// No description provided for @pAnimFormatHelp.
  ///
  /// In ru, this message translates to:
  /// **'GIF ограничен 256 цветами, поэтому для него строится оптимальная палитра под конкретное видео. WebP даёт полноцветную анимацию в 2–5 раз меньше. APNG — без потерь, но тяжёлый. По умолчанию: GIF.'**
  String get pAnimFormatHelp;

  /// No description provided for @pDuration.
  ///
  /// In ru, this message translates to:
  /// **'Длительность'**
  String get pDuration;

  /// No description provided for @pDurationHint.
  ///
  /// In ru, this message translates to:
  /// **'Пусто — до конца файла'**
  String get pDurationHint;

  /// No description provided for @pGifFps.
  ///
  /// In ru, this message translates to:
  /// **'Кадров в секунду'**
  String get pGifFps;

  /// No description provided for @pGifFpsHint.
  ///
  /// In ru, this message translates to:
  /// **'10–15 обычно достаточно'**
  String get pGifFpsHint;

  /// No description provided for @pGifWidth.
  ///
  /// In ru, this message translates to:
  /// **'Ширина'**
  String get pGifWidth;

  /// No description provided for @pGifWidthHint.
  ///
  /// In ru, this message translates to:
  /// **'Высота подберётся по пропорциям'**
  String get pGifWidthHint;

  /// No description provided for @pDither.
  ///
  /// In ru, this message translates to:
  /// **'Дизеринг'**
  String get pDither;

  /// No description provided for @pDitherHint.
  ///
  /// In ru, this message translates to:
  /// **'Как имитировать недостающие цвета'**
  String get pDitherHint;

  /// No description provided for @pDitherHelp.
  ///
  /// In ru, this message translates to:
  /// **'Sierra — мягкий и аккуратный (по умолчанию). Floyd–Steinberg — больше деталей, больше «шума». Bayer — регулярный узор, хорошо сжимается. Без дизеринга — полосы на градиентах, но меньше файл.'**
  String get pDitherHelp;

  /// No description provided for @pStaticBg.
  ///
  /// In ru, this message translates to:
  /// **'Статичный фон'**
  String get pStaticBg;

  /// No description provided for @pStaticBgHint.
  ///
  /// In ru, this message translates to:
  /// **'Лучше цвета, если двигается только часть кадра'**
  String get pStaticBgHint;

  /// No description provided for @pWebpQuality.
  ///
  /// In ru, this message translates to:
  /// **'Качество WebP'**
  String get pWebpQuality;

  /// No description provided for @pWebpQualityHint.
  ///
  /// In ru, this message translates to:
  /// **'75 — хороший баланс'**
  String get pWebpQualityHint;

  /// No description provided for @pLoop.
  ///
  /// In ru, this message translates to:
  /// **'Зациклить'**
  String get pLoop;

  /// No description provided for @pLoopHint.
  ///
  /// In ru, this message translates to:
  /// **'Повторять анимацию бесконечно'**
  String get pLoopHint;

  /// No description provided for @gifFrames.
  ///
  /// In ru, this message translates to:
  /// **'{count} кадров'**
  String gifFrames(int count);

  /// No description provided for @urlsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ссылки'**
  String get urlsLabel;

  /// No description provided for @urlsHint.
  ///
  /// In ru, this message translates to:
  /// **'Вставьте одну или несколько ссылок (на видео, плейлист или канал)'**
  String get urlsHint;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In ru, this message translates to:
  /// **'Вставить из буфера: {url}'**
  String pasteFromClipboard(String url);

  /// No description provided for @analyzeLinks.
  ///
  /// In ru, this message translates to:
  /// **'Получить информацию'**
  String get analyzeLinks;

  /// No description provided for @downloadWithoutAnalysis.
  ///
  /// In ru, this message translates to:
  /// **'Скачать сразу'**
  String get downloadWithoutAnalysis;

  /// No description provided for @download.
  ///
  /// In ru, this message translates to:
  /// **'Скачать'**
  String get download;

  /// No description provided for @downloadN.
  ///
  /// In ru, this message translates to:
  /// **'Скачать ({count})'**
  String downloadN(int count);

  /// No description provided for @downloadsQueued.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{В очередь добавлена {count} загрузка} few{В очередь добавлено {count} загрузки} many{В очередь добавлено {count} загрузок} other{В очередь добавлено {count} загрузки}}'**
  String downloadsQueued(int count);

  /// No description provided for @downloadsNeedYtdlpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нужен yt-dlp'**
  String get downloadsNeedYtdlpTitle;

  /// No description provided for @denoHint.
  ///
  /// In ru, this message translates to:
  /// **'Совет: для YouTube установите Deno в «Компонентах» — без него часть форматов недоступна.'**
  String get denoHint;

  /// No description provided for @selectedOf.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано {selected} из {total}'**
  String selectedOf(int selected, int total);

  /// No description provided for @selectAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get selectAll;

  /// No description provided for @selectNone.
  ///
  /// In ru, this message translates to:
  /// **'Ни одного'**
  String get selectNone;

  /// No description provided for @rangesHint.
  ///
  /// In ru, this message translates to:
  /// **'Номера: 1,3,5-10'**
  String get rangesHint;

  /// No description provided for @availableQualities.
  ///
  /// In ru, this message translates to:
  /// **'Есть: {list}'**
  String availableQualities(String list);

  /// No description provided for @exactFormat.
  ///
  /// In ru, this message translates to:
  /// **'Точный формат (необязательно)'**
  String get exactFormat;

  /// No description provided for @exactFormatAuto.
  ///
  /// In ru, this message translates to:
  /// **'Автоматически по качеству ниже'**
  String get exactFormatAuto;

  /// No description provided for @videoOnly.
  ///
  /// In ru, this message translates to:
  /// **'только видео'**
  String get videoOnly;

  /// No description provided for @pYtQuality.
  ///
  /// In ru, this message translates to:
  /// **'Качество'**
  String get pYtQuality;

  /// No description provided for @pYtQualityHint.
  ///
  /// In ru, this message translates to:
  /// **'Лучшее доступное или не выше выбранного'**
  String get pYtQualityHint;

  /// No description provided for @ytBest.
  ///
  /// In ru, this message translates to:
  /// **'Лучшее'**
  String get ytBest;

  /// No description provided for @ytUpTo.
  ///
  /// In ru, this message translates to:
  /// **'до {height}'**
  String ytUpTo(String height);

  /// No description provided for @ytAudioOnly.
  ///
  /// In ru, this message translates to:
  /// **'Только звук'**
  String get ytAudioOnly;

  /// No description provided for @pYtAudioFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат звука'**
  String get pYtAudioFormat;

  /// No description provided for @pYtAudioFormatHint.
  ///
  /// In ru, this message translates to:
  /// **'В какой формат сохранить звук'**
  String get pYtAudioFormatHint;

  /// No description provided for @pYtContainerHint.
  ///
  /// In ru, this message translates to:
  /// **'MP4 — для совместимости, MKV — без ограничений'**
  String get pYtContainerHint;

  /// No description provided for @pYtContainerHelp.
  ///
  /// In ru, this message translates to:
  /// **'Сайты часто отдают видео и звук отдельно; yt-dlp склеивает их через ffmpeg в выбранный контейнер. Для MP4 предпочитаются H.264/AAC, чтобы не перекодировать. «Как на сайте» сохраняет исходный формат (часто WebM).'**
  String get pYtContainerHelp;

  /// No description provided for @ytContainerAuto.
  ///
  /// In ru, this message translates to:
  /// **'Как на сайте'**
  String get ytContainerAuto;

  /// No description provided for @pYtSubs.
  ///
  /// In ru, this message translates to:
  /// **'Субтитры'**
  String get pYtSubs;

  /// No description provided for @pYtSubsHint.
  ///
  /// In ru, this message translates to:
  /// **'Скачать и вшить субтитры авторов'**
  String get pYtSubsHint;

  /// No description provided for @pYtAutoSubs.
  ///
  /// In ru, this message translates to:
  /// **'Автоматические субтитры'**
  String get pYtAutoSubs;

  /// No description provided for @pYtAutoSubsHint.
  ///
  /// In ru, this message translates to:
  /// **'Сгенерированные сайтом (например, YouTube)'**
  String get pYtAutoSubsHint;

  /// No description provided for @pYtSubLangs.
  ///
  /// In ru, this message translates to:
  /// **'Языки субтитров'**
  String get pYtSubLangs;

  /// No description provided for @pYtSubLangsHint.
  ///
  /// In ru, this message translates to:
  /// **'Через запятую: ru,en или all'**
  String get pYtSubLangsHint;

  /// No description provided for @pYtEmbed.
  ///
  /// In ru, this message translates to:
  /// **'Обложка, метаданные и главы'**
  String get pYtEmbed;

  /// No description provided for @pYtEmbedHint.
  ///
  /// In ru, this message translates to:
  /// **'Вшить в файл'**
  String get pYtEmbedHint;

  /// No description provided for @pSponsorBlock.
  ///
  /// In ru, this message translates to:
  /// **'SponsorBlock'**
  String get pSponsorBlock;

  /// No description provided for @pSponsorBlockHint.
  ///
  /// In ru, this message translates to:
  /// **'Рекламные вставки авторов'**
  String get pSponsorBlockHint;

  /// No description provided for @pSponsorBlockHelp.
  ///
  /// In ru, this message translates to:
  /// **'Использует базу sponsor.ajay.app. «Отметить» добавляет главы, «Вырезать» удаляет спонсорские вставки, саморекламу и просьбы подписаться (требует перекодирования фрагментов).'**
  String get pSponsorBlockHelp;

  /// No description provided for @sbOff.
  ///
  /// In ru, this message translates to:
  /// **'Не трогать'**
  String get sbOff;

  /// No description provided for @sbMark.
  ///
  /// In ru, this message translates to:
  /// **'Отметить главами'**
  String get sbMark;

  /// No description provided for @sbRemove.
  ///
  /// In ru, this message translates to:
  /// **'Вырезать'**
  String get sbRemove;

  /// No description provided for @pCookies.
  ///
  /// In ru, this message translates to:
  /// **'Cookies из браузера'**
  String get pCookies;

  /// No description provided for @pCookiesHint.
  ///
  /// In ru, this message translates to:
  /// **'Для приватных, 18+ и «подтвердите, что вы не бот»'**
  String get pCookiesHint;

  /// No description provided for @pCookiesHelp.
  ///
  /// In ru, this message translates to:
  /// **'yt-dlp прочитает cookies входа из выбранного браузера, как будто видео открыли в нём. Браузер лучше закрыть (Chrome блокирует файл cookies). Cookies никуда не отправляются, кроме самого сайта.'**
  String get pCookiesHelp;

  /// No description provided for @pArchive.
  ///
  /// In ru, this message translates to:
  /// **'Не качать повторно'**
  String get pArchive;

  /// No description provided for @pArchiveHint.
  ///
  /// In ru, this message translates to:
  /// **'Вести список скачанного в папке загрузок'**
  String get pArchiveHint;

  /// No description provided for @pTemplate.
  ///
  /// In ru, this message translates to:
  /// **'Шаблон имени файла'**
  String get pTemplate;

  /// No description provided for @pTemplateHint.
  ///
  /// In ru, this message translates to:
  /// **'Поля yt-dlp: %(title)s, %(id)s, %(uploader)s…'**
  String get pTemplateHint;

  /// No description provided for @pTemplateHelp.
  ///
  /// In ru, this message translates to:
  /// **'Например: «%(uploader)s/%(title)s.%(ext)s» разложит видео по папкам каналов. Полный список полей — в документации yt-dlp (OUTPUT TEMPLATE).'**
  String get pTemplateHelp;

  /// No description provided for @pRateLimit.
  ///
  /// In ru, this message translates to:
  /// **'Ограничение скорости'**
  String get pRateLimit;

  /// No description provided for @pRateLimitHint.
  ///
  /// In ru, this message translates to:
  /// **'Например 5M = 5 МБ/с; пусто — без ограничения'**
  String get pRateLimitHint;

  /// No description provided for @pProxy.
  ///
  /// In ru, this message translates to:
  /// **'Прокси'**
  String get pProxy;

  /// No description provided for @pProxyHint.
  ///
  /// In ru, this message translates to:
  /// **'http://, https:// или socks5://'**
  String get pProxyHint;

  /// No description provided for @setNextToSource.
  ///
  /// In ru, this message translates to:
  /// **'Сохранять рядом с исходным'**
  String get setNextToSource;

  /// No description provided for @setNextToSourceHint.
  ///
  /// In ru, this message translates to:
  /// **'Результат в той же папке, что и исходный файл'**
  String get setNextToSourceHint;

  /// No description provided for @setAria2.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка через aria2c'**
  String get setAria2;

  /// No description provided for @setAria2Hint.
  ///
  /// In ru, this message translates to:
  /// **'Многопоточная загрузка, если aria2c установлен'**
  String get setAria2Hint;

  /// No description provided for @setAria2Help.
  ///
  /// In ru, this message translates to:
  /// **'aria2c открывает несколько соединений к серверу и часто качает быстрее на медленных серверах. Для YouTube обычно хватает встроенных параллельных фрагментов. По умолчанию: выключено.'**
  String get setAria2Help;
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
