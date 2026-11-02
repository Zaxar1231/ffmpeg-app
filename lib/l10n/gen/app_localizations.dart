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
  /// **'По времени, на равные части, по главам или по отмеченным точкам.'**
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
  /// **'Весь экран или его часть, с микрофоном и звуком компьютера.'**
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
  /// **'Стабильный'**
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
  /// **'Закончить с самым коротким'**
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
  /// **'Язык речи; «авто» определит сам'**
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
  /// **'yt-dlp нужен Deno, чтобы получить форматы YouTube; без него загрузка с YouTube обычно не работает.'**
  String get denoHint;

  /// No description provided for @denoRequiredTitle.
  ///
  /// In ru, this message translates to:
  /// **'Для YouTube нужен Deno'**
  String get denoRequiredTitle;

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

  /// No description provided for @toolAudioEditor.
  ///
  /// In ru, this message translates to:
  /// **'Аудиоредактор'**
  String get toolAudioEditor;

  /// No description provided for @toolAudioEditorDesc.
  ///
  /// In ru, this message translates to:
  /// **'Многодорожечный редактор: правка, эффекты, генераторы, анализ, запись.'**
  String get toolAudioEditorDesc;

  /// No description provided for @cut.
  ///
  /// In ru, this message translates to:
  /// **'Вырезать'**
  String get cut;

  /// No description provided for @paste.
  ///
  /// In ru, this message translates to:
  /// **'Вставить'**
  String get paste;

  /// No description provided for @undo.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get redo;

  /// No description provided for @undoX.
  ///
  /// In ru, this message translates to:
  /// **'Отменить: {action}'**
  String undoX(String action);

  /// No description provided for @redoX.
  ///
  /// In ru, this message translates to:
  /// **'Повторить: {action}'**
  String redoX(String action);

  /// No description provided for @preview.
  ///
  /// In ru, this message translates to:
  /// **'Прослушать'**
  String get preview;

  /// No description provided for @generate.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get generate;

  /// No description provided for @export.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт'**
  String get export;

  /// No description provided for @record.
  ///
  /// In ru, this message translates to:
  /// **'Запись'**
  String get record;

  /// No description provided for @stop.
  ///
  /// In ru, this message translates to:
  /// **'Стоп'**
  String get stop;

  /// No description provided for @mute.
  ///
  /// In ru, this message translates to:
  /// **'Заглушить'**
  String get mute;

  /// No description provided for @solo.
  ///
  /// In ru, this message translates to:
  /// **'Соло'**
  String get solo;

  /// No description provided for @moveUp.
  ///
  /// In ru, this message translates to:
  /// **'Выше'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In ru, this message translates to:
  /// **'Ниже'**
  String get moveDown;

  /// No description provided for @zoomIn.
  ///
  /// In ru, this message translates to:
  /// **'Приблизить (Ctrl+=)'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In ru, this message translates to:
  /// **'Отдалить (Ctrl+−)'**
  String get zoomOut;

  /// No description provided for @zoomSelection.
  ///
  /// In ru, this message translates to:
  /// **'По выделению (Ctrl+E)'**
  String get zoomSelection;

  /// No description provided for @zoomFit.
  ///
  /// In ru, this message translates to:
  /// **'Весь проект (Ctrl+F)'**
  String get zoomFit;

  /// No description provided for @unitDb.
  ///
  /// In ru, this message translates to:
  /// **'дБ'**
  String get unitDb;

  /// No description provided for @unitMs.
  ///
  /// In ru, this message translates to:
  /// **'мс'**
  String get unitMs;

  /// No description provided for @unitSemitones.
  ///
  /// In ru, this message translates to:
  /// **'полутонов'**
  String get unitSemitones;

  /// No description provided for @unitBpm.
  ///
  /// In ru, this message translates to:
  /// **'уд/мин'**
  String get unitBpm;

  /// No description provided for @unitDbOct.
  ///
  /// In ru, this message translates to:
  /// **'дБ/окт'**
  String get unitDbOct;

  /// No description provided for @menuFile.
  ///
  /// In ru, this message translates to:
  /// **'Файл'**
  String get menuFile;

  /// No description provided for @menuEdit.
  ///
  /// In ru, this message translates to:
  /// **'Правка'**
  String get menuEdit;

  /// No description provided for @menuGenerate.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get menuGenerate;

  /// No description provided for @menuEffects.
  ///
  /// In ru, this message translates to:
  /// **'Эффекты'**
  String get menuEffects;

  /// No description provided for @menuAnalyze.
  ///
  /// In ru, this message translates to:
  /// **'Анализ'**
  String get menuAnalyze;

  /// No description provided for @menuTracks.
  ///
  /// In ru, this message translates to:
  /// **'Дорожки'**
  String get menuTracks;

  /// No description provided for @aeNew.
  ///
  /// In ru, this message translates to:
  /// **'Новый проект'**
  String get aeNew;

  /// No description provided for @aeOpenProject.
  ///
  /// In ru, this message translates to:
  /// **'Открыть проект…'**
  String get aeOpenProject;

  /// No description provided for @aeSaveProject.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить проект'**
  String get aeSaveProject;

  /// No description provided for @aeSaveProjectAs.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить проект как…'**
  String get aeSaveProjectAs;

  /// No description provided for @aeImport.
  ///
  /// In ru, this message translates to:
  /// **'Импорт аудио…'**
  String get aeImport;

  /// No description provided for @aeImportLabels.
  ///
  /// In ru, this message translates to:
  /// **'Импорт меток…'**
  String get aeImportLabels;

  /// No description provided for @aeExportLabels.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт меток…'**
  String get aeExportLabels;

  /// No description provided for @aeDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get aeDelete;

  /// No description provided for @aeSilence.
  ///
  /// In ru, this message translates to:
  /// **'Заполнить тишиной'**
  String get aeSilence;

  /// No description provided for @aeTrim.
  ///
  /// In ru, this message translates to:
  /// **'Оставить только выделенное'**
  String get aeTrim;

  /// No description provided for @aeDuplicate.
  ///
  /// In ru, this message translates to:
  /// **'Дублировать в новую дорожку'**
  String get aeDuplicate;

  /// No description provided for @aeSplitNew.
  ///
  /// In ru, this message translates to:
  /// **'Отделить в новую дорожку'**
  String get aeSplitNew;

  /// No description provided for @aeCrossfade.
  ///
  /// In ru, this message translates to:
  /// **'Плавный переход в точке курсора'**
  String get aeCrossfade;

  /// No description provided for @aeSelectAll.
  ///
  /// In ru, this message translates to:
  /// **'Выделить всё'**
  String get aeSelectAll;

  /// No description provided for @aeNoiseProfile.
  ///
  /// In ru, this message translates to:
  /// **'Взять профиль шума из выделения'**
  String get aeNoiseProfile;

  /// No description provided for @addLabel.
  ///
  /// In ru, this message translates to:
  /// **'Добавить метку'**
  String get addLabel;

  /// No description provided for @editLabel.
  ///
  /// In ru, this message translates to:
  /// **'Изменить метку'**
  String get editLabel;

  /// No description provided for @labelText.
  ///
  /// In ru, this message translates to:
  /// **'Текст метки'**
  String get labelText;

  /// No description provided for @labelHint.
  ///
  /// In ru, this message translates to:
  /// **'Клик — выделить, двойной клик — переименовать, правый клик — удалить'**
  String get labelHint;

  /// No description provided for @labelsTrack.
  ///
  /// In ru, this message translates to:
  /// **'Метки'**
  String get labelsTrack;

  /// No description provided for @labelsAdded.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Добавлена {count} метка} few{Добавлено {count} метки} many{Добавлено {count} меток} other{Добавлено {count} метки}}'**
  String labelsAdded(int count);

  /// No description provided for @aeAddTrack.
  ///
  /// In ru, this message translates to:
  /// **'Добавить дорожку из файла…'**
  String get aeAddTrack;

  /// No description provided for @aeMixRender.
  ///
  /// In ru, this message translates to:
  /// **'Свести в новую дорожку'**
  String get aeMixRender;

  /// No description provided for @aeSplitStereo.
  ///
  /// In ru, this message translates to:
  /// **'Разделить стерео на моно'**
  String get aeSplitStereo;

  /// No description provided for @aeSpectrogramView.
  ///
  /// In ru, this message translates to:
  /// **'Показать спектрограмму'**
  String get aeSpectrogramView;

  /// No description provided for @aeWaveformView.
  ///
  /// In ru, this message translates to:
  /// **'Показать волну'**
  String get aeWaveformView;

  /// No description provided for @aeClearEnvelope.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить огибающую'**
  String get aeClearEnvelope;

  /// No description provided for @aeRemoveTrack.
  ///
  /// In ru, this message translates to:
  /// **'Удалить дорожку'**
  String get aeRemoveTrack;

  /// No description provided for @trackName.
  ///
  /// In ru, this message translates to:
  /// **'Имя дорожки'**
  String get trackName;

  /// No description provided for @trackGain.
  ///
  /// In ru, this message translates to:
  /// **'Громкость дорожки'**
  String get trackGain;

  /// No description provided for @trackPan.
  ///
  /// In ru, this message translates to:
  /// **'Панорама'**
  String get trackPan;

  /// No description provided for @aePlayHint.
  ///
  /// In ru, this message translates to:
  /// **'Воспроизвести / пауза (Пробел)'**
  String get aePlayHint;

  /// No description provided for @aePlaySelection.
  ///
  /// In ru, this message translates to:
  /// **'Воспроизвести выделение (Shift+Пробел)'**
  String get aePlaySelection;

  /// No description provided for @aeLoop.
  ///
  /// In ru, this message translates to:
  /// **'Повтор выделения'**
  String get aeLoop;

  /// No description provided for @toolSelect.
  ///
  /// In ru, this message translates to:
  /// **'Выделение'**
  String get toolSelect;

  /// No description provided for @toolShift.
  ///
  /// In ru, this message translates to:
  /// **'Сдвиг во времени'**
  String get toolShift;

  /// No description provided for @toolEnvelope.
  ///
  /// In ru, this message translates to:
  /// **'Огибающая громкости'**
  String get toolEnvelope;

  /// No description provided for @aeCursorAt.
  ///
  /// In ru, this message translates to:
  /// **'Курсор: {time}'**
  String aeCursorAt(String time);

  /// No description provided for @aeSelectionInfo.
  ///
  /// In ru, this message translates to:
  /// **'Выделение: {start} – {end} ({length})'**
  String aeSelectionInfo(String start, String end, String length);

  /// No description provided for @aeEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Аудиоредактор'**
  String get aeEmptyTitle;

  /// No description provided for @aeEmptyBody.
  ///
  /// In ru, this message translates to:
  /// **'Перетащите сюда аудио или видео, откройте проект или начните запись с микрофона.'**
  String get aeEmptyBody;

  /// No description provided for @aeNeedSelection.
  ///
  /// In ru, this message translates to:
  /// **'Сначала выделите фрагмент.'**
  String get aeNeedSelection;

  /// No description provided for @aeStatusHint.
  ///
  /// In ru, this message translates to:
  /// **'Перетаскивайте по волне, чтобы выделить; Ctrl+колесо — масштаб, Shift+колесо — прокрутка; клик по имени дорожки — выбрать её.'**
  String get aeStatusHint;

  /// No description provided for @applyToSelection.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Применится к выделению на {count} дорожке} other{Применится к выделению на {count} дорожках}}'**
  String applyToSelection(int count);

  /// No description provided for @applyToWholeTracks.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Выделения нет — применится ко всей дорожке} other{Выделения нет — применится к {count} дорожкам целиком}}'**
  String applyToWholeTracks(int count);

  /// No description provided for @fxBrokenInBuild.
  ///
  /// In ru, this message translates to:
  /// **'Этот фильтр аварийно завершается в установленной сборке ffmpeg. Выберите другую сборку или откатитесь в «Компонентах».'**
  String get fxBrokenInBuild;

  /// No description provided for @fxStereoOnly.
  ///
  /// In ru, this message translates to:
  /// **'Эффект работает только со стерео — моно-дорожки будут пропущены.'**
  String get fxStereoOnly;

  /// No description provided for @fxDartDsp.
  ///
  /// In ru, this message translates to:
  /// **'Этого эффекта нет в ffmpeg, он выполняется встроенным обработчиком Kadra.'**
  String get fxDartDsp;

  /// No description provided for @useNoiseProfile.
  ///
  /// In ru, this message translates to:
  /// **'Использовать профиль шума'**
  String get useNoiseProfile;

  /// No description provided for @noNoiseProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиля нет: выделите участок, где только шум, и выберите «Правка → Взять профиль шума».'**
  String get noNoiseProfile;

  /// No description provided for @noiseProfileReady.
  ///
  /// In ru, this message translates to:
  /// **'Профиль шума: {seconds} с'**
  String noiseProfileReady(String seconds);

  /// No description provided for @noiseProfileShort.
  ///
  /// In ru, this message translates to:
  /// **'профиль шума'**
  String get noiseProfileShort;

  /// No description provided for @controlTrack.
  ///
  /// In ru, this message translates to:
  /// **'Управляющая дорожка (голос)'**
  String get controlTrack;

  /// No description provided for @chooseTrack.
  ///
  /// In ru, this message translates to:
  /// **'Выберите дорожку'**
  String get chooseTrack;

  /// No description provided for @flatten.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить в ноль'**
  String get flatten;

  /// No description provided for @generateReplaces.
  ///
  /// In ru, this message translates to:
  /// **'Есть выделение — оно будет заменено сгенерированным звуком.'**
  String get generateReplaces;

  /// No description provided for @generateInserts.
  ///
  /// In ru, this message translates to:
  /// **'Звук будет вставлен в позицию курсора.'**
  String get generateInserts;

  /// No description provided for @dtmfDigits.
  ///
  /// In ru, this message translates to:
  /// **'Цифры и символы (0–9, *, #, A–D)'**
  String get dtmfDigits;

  /// No description provided for @anStats.
  ///
  /// In ru, this message translates to:
  /// **'Статистика и громкость'**
  String get anStats;

  /// No description provided for @anSpectrum.
  ///
  /// In ru, this message translates to:
  /// **'Спектр частот'**
  String get anSpectrum;

  /// No description provided for @anSounds.
  ///
  /// In ru, this message translates to:
  /// **'Найти звуки'**
  String get anSounds;

  /// No description provided for @anSilence.
  ///
  /// In ru, this message translates to:
  /// **'Найти тишину'**
  String get anSilence;

  /// No description provided for @anBeats.
  ///
  /// In ru, this message translates to:
  /// **'Найти сильные доли'**
  String get anBeats;

  /// No description provided for @anClipping.
  ///
  /// In ru, this message translates to:
  /// **'Найти перегрузку (клиппинг)'**
  String get anClipping;

  /// No description provided for @findAndLabel.
  ///
  /// In ru, this message translates to:
  /// **'Найти и отметить'**
  String get findAndLabel;

  /// No description provided for @channelN.
  ///
  /// In ru, this message translates to:
  /// **'Канал {n}'**
  String channelN(int n);

  /// No description provided for @statPeak.
  ///
  /// In ru, this message translates to:
  /// **'Пиковый уровень'**
  String get statPeak;

  /// No description provided for @statRms.
  ///
  /// In ru, this message translates to:
  /// **'Средний уровень (RMS)'**
  String get statRms;

  /// No description provided for @statDc.
  ///
  /// In ru, this message translates to:
  /// **'Смещение постоянной составляющей'**
  String get statDc;

  /// No description provided for @statClipped.
  ///
  /// In ru, this message translates to:
  /// **'Сэмплов в перегрузке'**
  String get statClipped;

  /// No description provided for @statIntegrated.
  ///
  /// In ru, this message translates to:
  /// **'Интегральная громкость'**
  String get statIntegrated;

  /// No description provided for @statLra.
  ///
  /// In ru, this message translates to:
  /// **'Диапазон громкости'**
  String get statLra;

  /// No description provided for @statTruePeak.
  ///
  /// In ru, this message translates to:
  /// **'Истинный пик'**
  String get statTruePeak;

  /// No description provided for @exportAudio.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт аудио…'**
  String get exportAudio;

  /// No description provided for @exportAll.
  ///
  /// In ru, this message translates to:
  /// **'Весь проект'**
  String get exportAll;

  /// No description provided for @exportSelection.
  ///
  /// In ru, this message translates to:
  /// **'Выделение'**
  String get exportSelection;

  /// No description provided for @exportByLabels.
  ///
  /// In ru, this message translates to:
  /// **'По меткам (несколько файлов)'**
  String get exportByLabels;

  /// No description provided for @aeExportSelection.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт выделения…'**
  String get aeExportSelection;

  /// No description provided for @aeExportByLabels.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт по меткам…'**
  String get aeExportByLabels;

  /// No description provided for @metadataTitle.
  ///
  /// In ru, this message translates to:
  /// **'Метаданные'**
  String get metadataTitle;

  /// No description provided for @metaTitle.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get metaTitle;

  /// No description provided for @metaArtist.
  ///
  /// In ru, this message translates to:
  /// **'Исполнитель'**
  String get metaArtist;

  /// No description provided for @metaAlbum.
  ///
  /// In ru, this message translates to:
  /// **'Альбом'**
  String get metaAlbum;

  /// No description provided for @metaYear.
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get metaYear;

  /// No description provided for @metaGenre.
  ///
  /// In ru, this message translates to:
  /// **'Жанр'**
  String get metaGenre;

  /// No description provided for @metaTrack.
  ///
  /// In ru, this message translates to:
  /// **'Номер трека'**
  String get metaTrack;

  /// No description provided for @metaComment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get metaComment;

  /// No description provided for @recordTitle.
  ///
  /// In ru, this message translates to:
  /// **'Запись'**
  String get recordTitle;

  /// No description provided for @noRecordingDevices.
  ///
  /// In ru, this message translates to:
  /// **'Устройства записи не найдены.'**
  String get noRecordingDevices;

  /// No description provided for @recordHint.
  ///
  /// In ru, this message translates to:
  /// **'Запись появится новой дорожкой с позиции курсора.'**
  String get recordHint;

  /// No description provided for @histImport.
  ///
  /// In ru, this message translates to:
  /// **'импорт'**
  String get histImport;

  /// No description provided for @histDelete.
  ///
  /// In ru, this message translates to:
  /// **'удаление'**
  String get histDelete;

  /// No description provided for @histSilence.
  ///
  /// In ru, this message translates to:
  /// **'тишина'**
  String get histSilence;

  /// No description provided for @histTrim.
  ///
  /// In ru, this message translates to:
  /// **'обрезка'**
  String get histTrim;

  /// No description provided for @histPaste.
  ///
  /// In ru, this message translates to:
  /// **'вставка'**
  String get histPaste;

  /// No description provided for @histDuplicate.
  ///
  /// In ru, this message translates to:
  /// **'дублирование'**
  String get histDuplicate;

  /// No description provided for @histSplitNew.
  ///
  /// In ru, this message translates to:
  /// **'отделение'**
  String get histSplitNew;

  /// No description provided for @histCrossfade.
  ///
  /// In ru, this message translates to:
  /// **'плавный переход'**
  String get histCrossfade;

  /// No description provided for @histRemoveTrack.
  ///
  /// In ru, this message translates to:
  /// **'удаление дорожки'**
  String get histRemoveTrack;

  /// No description provided for @histMoveTrack.
  ///
  /// In ru, this message translates to:
  /// **'перемещение дорожки'**
  String get histMoveTrack;

  /// No description provided for @histMixRender.
  ///
  /// In ru, this message translates to:
  /// **'сведение'**
  String get histMixRender;

  /// No description provided for @histSplitStereo.
  ///
  /// In ru, this message translates to:
  /// **'разделение стерео'**
  String get histSplitStereo;

  /// No description provided for @histLabels.
  ///
  /// In ru, this message translates to:
  /// **'метки'**
  String get histLabels;

  /// No description provided for @histRecord.
  ///
  /// In ru, this message translates to:
  /// **'запись'**
  String get histRecord;

  /// No description provided for @histTrack.
  ///
  /// In ru, this message translates to:
  /// **'изменение дорожки'**
  String get histTrack;

  /// No description provided for @fxcVolume.
  ///
  /// In ru, this message translates to:
  /// **'Громкость и динамика'**
  String get fxcVolume;

  /// No description provided for @fxcFades.
  ///
  /// In ru, this message translates to:
  /// **'Затухания'**
  String get fxcFades;

  /// No description provided for @fxcEq.
  ///
  /// In ru, this message translates to:
  /// **'Эквалайзер и фильтры'**
  String get fxcEq;

  /// No description provided for @fxcNoise.
  ///
  /// In ru, this message translates to:
  /// **'Шум и ремонт'**
  String get fxcNoise;

  /// No description provided for @fxcPitchTempo.
  ///
  /// In ru, this message translates to:
  /// **'Высота и темп'**
  String get fxcPitchTempo;

  /// No description provided for @fxcDelayReverb.
  ///
  /// In ru, this message translates to:
  /// **'Задержка и реверберация'**
  String get fxcDelayReverb;

  /// No description provided for @fxcDistortion.
  ///
  /// In ru, this message translates to:
  /// **'Искажение и модуляция'**
  String get fxcDistortion;

  /// No description provided for @fxcSpecial.
  ///
  /// In ru, this message translates to:
  /// **'Специальные'**
  String get fxcSpecial;

  /// No description provided for @fxAmplify.
  ///
  /// In ru, this message translates to:
  /// **'Усиление'**
  String get fxAmplify;

  /// No description provided for @fxAmplifyDesc.
  ///
  /// In ru, this message translates to:
  /// **'Делает звук громче или тише на заданное число децибел.'**
  String get fxAmplifyDesc;

  /// No description provided for @fxNormalize.
  ///
  /// In ru, this message translates to:
  /// **'Нормализация пика'**
  String get fxNormalize;

  /// No description provided for @fxNormalizeDesc.
  ///
  /// In ru, this message translates to:
  /// **'Поднимает уровень так, чтобы пик достиг заданного значения; может убрать смещение DC.'**
  String get fxNormalizeDesc;

  /// No description provided for @fxLoudness.
  ///
  /// In ru, this message translates to:
  /// **'Нормализация громкости (LUFS)'**
  String get fxLoudness;

  /// No description provided for @fxLoudnessDesc.
  ///
  /// In ru, this message translates to:
  /// **'Приводит воспринимаемую громкость к цели по EBU R128 (два прохода).'**
  String get fxLoudnessDesc;

  /// No description provided for @fxCompressor.
  ///
  /// In ru, this message translates to:
  /// **'Компрессор'**
  String get fxCompressor;

  /// No description provided for @fxCompressorDesc.
  ///
  /// In ru, this message translates to:
  /// **'Уменьшает разницу между громкими и тихими местами.'**
  String get fxCompressorDesc;

  /// No description provided for @fxLimiter.
  ///
  /// In ru, this message translates to:
  /// **'Лимитер'**
  String get fxLimiter;

  /// No description provided for @fxLimiterDesc.
  ///
  /// In ru, this message translates to:
  /// **'Не даёт пикам превысить заданный уровень.'**
  String get fxLimiterDesc;

  /// No description provided for @fxGate.
  ///
  /// In ru, this message translates to:
  /// **'Шумовой гейт'**
  String get fxGate;

  /// No description provided for @fxGateDesc.
  ///
  /// In ru, this message translates to:
  /// **'Приглушает звук, когда он тише порога (паузы между фразами).'**
  String get fxGateDesc;

  /// No description provided for @fxAutoDuck.
  ///
  /// In ru, this message translates to:
  /// **'Автоприглушение'**
  String get fxAutoDuck;

  /// No description provided for @fxAutoDuckDesc.
  ///
  /// In ru, this message translates to:
  /// **'Приглушает музыку, когда звучит голос на другой дорожке.'**
  String get fxAutoDuckDesc;

  /// No description provided for @fxDynamicNormalizer.
  ///
  /// In ru, this message translates to:
  /// **'Динамический нормализатор'**
  String get fxDynamicNormalizer;

  /// No description provided for @fxDynamicNormalizerDesc.
  ///
  /// In ru, this message translates to:
  /// **'Выравнивает громкость по ходу записи, не трогая короткую динамику.'**
  String get fxDynamicNormalizerDesc;

  /// No description provided for @fxSpeechNormalizer.
  ///
  /// In ru, this message translates to:
  /// **'Нормализатор речи'**
  String get fxSpeechNormalizer;

  /// No description provided for @fxSpeechNormalizerDesc.
  ///
  /// In ru, this message translates to:
  /// **'Выравнивает громкость речи: тихие фразы громче, громкие тише.'**
  String get fxSpeechNormalizerDesc;

  /// No description provided for @fxFadeIn.
  ///
  /// In ru, this message translates to:
  /// **'Плавное нарастание'**
  String get fxFadeIn;

  /// No description provided for @fxFadeOut.
  ///
  /// In ru, this message translates to:
  /// **'Плавное затухание'**
  String get fxFadeOut;

  /// No description provided for @fxStudioFadeOut.
  ///
  /// In ru, this message translates to:
  /// **'Студийное затухание'**
  String get fxStudioFadeOut;

  /// No description provided for @fxAdjustableFade.
  ///
  /// In ru, this message translates to:
  /// **'Настраиваемое затухание'**
  String get fxAdjustableFade;

  /// No description provided for @fxAdjustableFadeDesc.
  ///
  /// In ru, this message translates to:
  /// **'Меняет громкость от одного процента до другого по выделению.'**
  String get fxAdjustableFadeDesc;

  /// No description provided for @fxBassTreble.
  ///
  /// In ru, this message translates to:
  /// **'Басы и высокие'**
  String get fxBassTreble;

  /// No description provided for @fxBassTrebleDesc.
  ///
  /// In ru, this message translates to:
  /// **'Поднимает или срезает низкие и высокие частоты.'**
  String get fxBassTrebleDesc;

  /// No description provided for @fxGraphicEq.
  ///
  /// In ru, this message translates to:
  /// **'Графический эквалайзер'**
  String get fxGraphicEq;

  /// No description provided for @fxGraphicEqDesc.
  ///
  /// In ru, this message translates to:
  /// **'18 полос от 65 Гц до 20 кГц.'**
  String get fxGraphicEqDesc;

  /// No description provided for @fxParametricEq.
  ///
  /// In ru, this message translates to:
  /// **'Параметрический эквалайзер'**
  String get fxParametricEq;

  /// No description provided for @fxParametricEqDesc.
  ///
  /// In ru, this message translates to:
  /// **'Четыре полосы: частота, усиление и добротность каждой.'**
  String get fxParametricEqDesc;

  /// No description provided for @fxHighPass.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр высоких частот'**
  String get fxHighPass;

  /// No description provided for @fxLowPass.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр низких частот'**
  String get fxLowPass;

  /// No description provided for @fxBandPass.
  ///
  /// In ru, this message translates to:
  /// **'Полосовой фильтр'**
  String get fxBandPass;

  /// No description provided for @fxNotch.
  ///
  /// In ru, this message translates to:
  /// **'Режекторный фильтр'**
  String get fxNotch;

  /// No description provided for @fxNotchDesc.
  ///
  /// In ru, this message translates to:
  /// **'Вырезает узкую полосу частот (например, писк).'**
  String get fxNotchDesc;

  /// No description provided for @fxHumRemoval.
  ///
  /// In ru, this message translates to:
  /// **'Удаление фона сети'**
  String get fxHumRemoval;

  /// No description provided for @fxHumRemovalDesc.
  ///
  /// In ru, this message translates to:
  /// **'Убирает гул 50/60 Гц и его гармоники.'**
  String get fxHumRemovalDesc;

  /// No description provided for @fxDeesser.
  ///
  /// In ru, this message translates to:
  /// **'Де-эссер'**
  String get fxDeesser;

  /// No description provided for @fxDeesserDesc.
  ///
  /// In ru, this message translates to:
  /// **'Смягчает резкие «с» и «ш».'**
  String get fxDeesserDesc;

  /// No description provided for @fxExciter.
  ///
  /// In ru, this message translates to:
  /// **'Эксайтер'**
  String get fxExciter;

  /// No description provided for @fxExciterDesc.
  ///
  /// In ru, this message translates to:
  /// **'Добавляет яркости и разборчивости высоким частотам.'**
  String get fxExciterDesc;

  /// No description provided for @fxNoiseReduction.
  ///
  /// In ru, this message translates to:
  /// **'Подавление шума'**
  String get fxNoiseReduction;

  /// No description provided for @fxNoiseReductionDesc.
  ///
  /// In ru, this message translates to:
  /// **'Убирает постоянный шум (шипение, гул). Лучше всего — с профилем шума из участка без речи.'**
  String get fxNoiseReductionDesc;

  /// No description provided for @fxNlmDenoise.
  ///
  /// In ru, this message translates to:
  /// **'Шумоподавление NLM'**
  String get fxNlmDenoise;

  /// No description provided for @fxNlmDenoiseDesc.
  ///
  /// In ru, this message translates to:
  /// **'Шумоподавление по нелокальным средним: мягче, но медленнее.'**
  String get fxNlmDenoiseDesc;

  /// No description provided for @fxClickRemoval.
  ///
  /// In ru, this message translates to:
  /// **'Удаление щелчков'**
  String get fxClickRemoval;

  /// No description provided for @fxClickRemovalDesc.
  ///
  /// In ru, this message translates to:
  /// **'Убирает щелчки и треск (виниловые записи).'**
  String get fxClickRemovalDesc;

  /// No description provided for @fxClipFix.
  ///
  /// In ru, this message translates to:
  /// **'Восстановление перегрузки'**
  String get fxClipFix;

  /// No description provided for @fxClipFixDesc.
  ///
  /// In ru, this message translates to:
  /// **'Восстанавливает срезанные вершины волны.'**
  String get fxClipFixDesc;

  /// No description provided for @fxChangePitch.
  ///
  /// In ru, this message translates to:
  /// **'Смена высоты тона'**
  String get fxChangePitch;

  /// No description provided for @fxChangePitchDesc.
  ///
  /// In ru, this message translates to:
  /// **'Меняет высоту без изменения темпа.'**
  String get fxChangePitchDesc;

  /// No description provided for @fxChangeTempo.
  ///
  /// In ru, this message translates to:
  /// **'Смена темпа'**
  String get fxChangeTempo;

  /// No description provided for @fxChangeTempoDesc.
  ///
  /// In ru, this message translates to:
  /// **'Меняет темп без изменения высоты тона.'**
  String get fxChangeTempoDesc;

  /// No description provided for @fxChangeSpeed.
  ///
  /// In ru, this message translates to:
  /// **'Смена скорости'**
  String get fxChangeSpeed;

  /// No description provided for @fxChangeSpeedDesc.
  ///
  /// In ru, this message translates to:
  /// **'Меняет скорость и высоту вместе, как на магнитофоне.'**
  String get fxChangeSpeedDesc;

  /// No description provided for @fxSlidingSpeed.
  ///
  /// In ru, this message translates to:
  /// **'Плавное изменение скорости'**
  String get fxSlidingSpeed;

  /// No description provided for @fxSlidingSpeedDesc.
  ///
  /// In ru, this message translates to:
  /// **'Скорость плавно меняется от начала к концу выделения.'**
  String get fxSlidingSpeedDesc;

  /// No description provided for @fxPaulstretch.
  ///
  /// In ru, this message translates to:
  /// **'Paulstretch'**
  String get fxPaulstretch;

  /// No description provided for @fxPaulstretchDesc.
  ///
  /// In ru, this message translates to:
  /// **'Экстремальное растяжение во времени: превращает звук в атмосферный эмбиент.'**
  String get fxPaulstretchDesc;

  /// No description provided for @fxEcho.
  ///
  /// In ru, this message translates to:
  /// **'Эхо'**
  String get fxEcho;

  /// No description provided for @fxEchoDesc.
  ///
  /// In ru, this message translates to:
  /// **'Повторения звука с затуханием.'**
  String get fxEchoDesc;

  /// No description provided for @fxReverb.
  ///
  /// In ru, this message translates to:
  /// **'Реверберация'**
  String get fxReverb;

  /// No description provided for @fxReverbDesc.
  ///
  /// In ru, this message translates to:
  /// **'Звучание помещения: от комнаты до собора.'**
  String get fxReverbDesc;

  /// No description provided for @fxDistortion.
  ///
  /// In ru, this message translates to:
  /// **'Искажение'**
  String get fxDistortion;

  /// No description provided for @fxDistortionDesc.
  ///
  /// In ru, this message translates to:
  /// **'Перегруз разных типов: мягкий ламповый или жёсткий.'**
  String get fxDistortionDesc;

  /// No description provided for @fxBitcrusher.
  ///
  /// In ru, this message translates to:
  /// **'Биткрашер'**
  String get fxBitcrusher;

  /// No description provided for @fxBitcrusherDesc.
  ///
  /// In ru, this message translates to:
  /// **'Снижает разрядность и частоту — «8-битный» звук.'**
  String get fxBitcrusherDesc;

  /// No description provided for @fxPhaser.
  ///
  /// In ru, this message translates to:
  /// **'Фейзер'**
  String get fxPhaser;

  /// No description provided for @fxFlanger.
  ///
  /// In ru, this message translates to:
  /// **'Флэнжер'**
  String get fxFlanger;

  /// No description provided for @fxChorus.
  ///
  /// In ru, this message translates to:
  /// **'Хорус'**
  String get fxChorus;

  /// No description provided for @fxTremolo.
  ///
  /// In ru, this message translates to:
  /// **'Тремоло'**
  String get fxTremolo;

  /// No description provided for @fxTremoloDesc.
  ///
  /// In ru, this message translates to:
  /// **'Периодически меняет громкость.'**
  String get fxTremoloDesc;

  /// No description provided for @fxVibrato.
  ///
  /// In ru, this message translates to:
  /// **'Вибрато'**
  String get fxVibrato;

  /// No description provided for @fxVibratoDesc.
  ///
  /// In ru, this message translates to:
  /// **'Периодически меняет высоту тона.'**
  String get fxVibratoDesc;

  /// No description provided for @fxWahwah.
  ///
  /// In ru, this message translates to:
  /// **'Вау-вау'**
  String get fxWahwah;

  /// No description provided for @fxWahwahDesc.
  ///
  /// In ru, this message translates to:
  /// **'Плавающий резонансный фильтр, как педаль у гитариста.'**
  String get fxWahwahDesc;

  /// No description provided for @fxAutoPan.
  ///
  /// In ru, this message translates to:
  /// **'Автопанорама'**
  String get fxAutoPan;

  /// No description provided for @fxAutoPanDesc.
  ///
  /// In ru, this message translates to:
  /// **'Звук плавно перемещается между каналами.'**
  String get fxAutoPanDesc;

  /// No description provided for @fxInvert.
  ///
  /// In ru, this message translates to:
  /// **'Инверсия'**
  String get fxInvert;

  /// No description provided for @fxInvertDesc.
  ///
  /// In ru, this message translates to:
  /// **'Переворачивает волну (фазу).'**
  String get fxInvertDesc;

  /// No description provided for @fxReverse.
  ///
  /// In ru, this message translates to:
  /// **'Реверс'**
  String get fxReverse;

  /// No description provided for @fxReverseDesc.
  ///
  /// In ru, this message translates to:
  /// **'Проигрывает выделение задом наперёд.'**
  String get fxReverseDesc;

  /// No description provided for @fxRepeat.
  ///
  /// In ru, this message translates to:
  /// **'Повтор'**
  String get fxRepeat;

  /// No description provided for @fxRepeatDesc.
  ///
  /// In ru, this message translates to:
  /// **'Повторяет выделение заданное число раз.'**
  String get fxRepeatDesc;

  /// No description provided for @fxTruncateSilence.
  ///
  /// In ru, this message translates to:
  /// **'Сокращение тишины'**
  String get fxTruncateSilence;

  /// No description provided for @fxTruncateSilenceDesc.
  ///
  /// In ru, this message translates to:
  /// **'Укорачивает длинные паузы.'**
  String get fxTruncateSilenceDesc;

  /// No description provided for @fxVocalRemove.
  ///
  /// In ru, this message translates to:
  /// **'Удаление вокала'**
  String get fxVocalRemove;

  /// No description provided for @fxVocalRemoveDesc.
  ///
  /// In ru, this message translates to:
  /// **'Убирает звук из центра стереопанорамы (обычно вокал), сохраняя басы.'**
  String get fxVocalRemoveDesc;

  /// No description provided for @fxVocalIsolate.
  ///
  /// In ru, this message translates to:
  /// **'Выделение вокала'**
  String get fxVocalIsolate;

  /// No description provided for @fxVocalIsolateDesc.
  ///
  /// In ru, this message translates to:
  /// **'Оставляет центр панорамы в полосе голоса.'**
  String get fxVocalIsolateDesc;

  /// No description provided for @fxSwapChannels.
  ///
  /// In ru, this message translates to:
  /// **'Поменять каналы местами'**
  String get fxSwapChannels;

  /// No description provided for @fxMonoMix.
  ///
  /// In ru, this message translates to:
  /// **'Свести в моно'**
  String get fxMonoMix;

  /// No description provided for @fxStereoWiden.
  ///
  /// In ru, this message translates to:
  /// **'Расширение стерео'**
  String get fxStereoWiden;

  /// No description provided for @fxStereoWidenDesc.
  ///
  /// In ru, this message translates to:
  /// **'Делает стереобазу шире.'**
  String get fxStereoWidenDesc;

  /// No description provided for @fxBalance.
  ///
  /// In ru, this message translates to:
  /// **'Баланс'**
  String get fxBalance;

  /// No description provided for @fxHaas.
  ///
  /// In ru, this message translates to:
  /// **'Эффект Хааса'**
  String get fxHaas;

  /// No description provided for @fxHaasDesc.
  ///
  /// In ru, this message translates to:
  /// **'Превращает моно в объёмное стерео за счёт небольшой задержки одного канала.'**
  String get fxHaasDesc;

  /// No description provided for @fxFadeDesc.
  ///
  /// In ru, this message translates to:
  /// **'Плавно меняет громкость на выделении.'**
  String get fxFadeDesc;

  /// No description provided for @fxPassDesc.
  ///
  /// In ru, this message translates to:
  /// **'Пропускает только нужные частоты; крутизна задаёт, насколько резко срезаются остальные.'**
  String get fxPassDesc;

  /// No description provided for @fxModulationDesc.
  ///
  /// In ru, this message translates to:
  /// **'Классический эффект модуляции задержкой.'**
  String get fxModulationDesc;

  /// No description provided for @fxChannelsDesc.
  ///
  /// In ru, this message translates to:
  /// **'Работа с каналами стерео.'**
  String get fxChannelsDesc;

  /// No description provided for @fxpGain.
  ///
  /// In ru, this message translates to:
  /// **'Усиление'**
  String get fxpGain;

  /// No description provided for @fxpPeak.
  ///
  /// In ru, this message translates to:
  /// **'Пик'**
  String get fxpPeak;

  /// No description provided for @fxpRemoveDc.
  ///
  /// In ru, this message translates to:
  /// **'Убрать смещение DC'**
  String get fxpRemoveDc;

  /// No description provided for @fxpIndependent.
  ///
  /// In ru, this message translates to:
  /// **'Каналы независимо'**
  String get fxpIndependent;

  /// No description provided for @fxpLufs.
  ///
  /// In ru, this message translates to:
  /// **'Целевая громкость'**
  String get fxpLufs;

  /// No description provided for @fxpTruePeak.
  ///
  /// In ru, this message translates to:
  /// **'Истинный пик, не выше'**
  String get fxpTruePeak;

  /// No description provided for @fxpThreshold.
  ///
  /// In ru, this message translates to:
  /// **'Порог'**
  String get fxpThreshold;

  /// No description provided for @fxpRatio.
  ///
  /// In ru, this message translates to:
  /// **'Степень сжатия'**
  String get fxpRatio;

  /// No description provided for @fxpAttack.
  ///
  /// In ru, this message translates to:
  /// **'Атака'**
  String get fxpAttack;

  /// No description provided for @fxpRelease.
  ///
  /// In ru, this message translates to:
  /// **'Восстановление'**
  String get fxpRelease;

  /// No description provided for @fxpMakeup.
  ///
  /// In ru, this message translates to:
  /// **'Компенсация усиления'**
  String get fxpMakeup;

  /// No description provided for @fxpKnee.
  ///
  /// In ru, this message translates to:
  /// **'Мягкость перегиба'**
  String get fxpKnee;

  /// No description provided for @fxpLimit.
  ///
  /// In ru, this message translates to:
  /// **'Предел'**
  String get fxpLimit;

  /// No description provided for @fxpReduction.
  ///
  /// In ru, this message translates to:
  /// **'Подавление'**
  String get fxpReduction;

  /// No description provided for @fxpGateReduction.
  ///
  /// In ru, this message translates to:
  /// **'Ослабление ниже порога'**
  String get fxpGateReduction;

  /// No description provided for @fxpDuck.
  ///
  /// In ru, this message translates to:
  /// **'Насколько приглушать'**
  String get fxpDuck;

  /// No description provided for @fxpFrame.
  ///
  /// In ru, this message translates to:
  /// **'Длина окна'**
  String get fxpFrame;

  /// No description provided for @fxpGauss.
  ///
  /// In ru, this message translates to:
  /// **'Сглаживание (окон)'**
  String get fxpGauss;

  /// No description provided for @fxpPeakLin.
  ///
  /// In ru, this message translates to:
  /// **'Целевой пик'**
  String get fxpPeakLin;

  /// No description provided for @fxpMaxGain.
  ///
  /// In ru, this message translates to:
  /// **'Макс. усиление'**
  String get fxpMaxGain;

  /// No description provided for @fxpExpansion.
  ///
  /// In ru, this message translates to:
  /// **'Макс. расширение'**
  String get fxpExpansion;

  /// No description provided for @fxpCompression.
  ///
  /// In ru, this message translates to:
  /// **'Макс. сжатие'**
  String get fxpCompression;

  /// No description provided for @fxpCurve.
  ///
  /// In ru, this message translates to:
  /// **'Форма кривой'**
  String get fxpCurve;

  /// No description provided for @fxpFrom.
  ///
  /// In ru, this message translates to:
  /// **'Начальная громкость'**
  String get fxpFrom;

  /// No description provided for @fxpTo.
  ///
  /// In ru, this message translates to:
  /// **'Конечная громкость'**
  String get fxpTo;

  /// No description provided for @fxpShape.
  ///
  /// In ru, this message translates to:
  /// **'Шкала'**
  String get fxpShape;

  /// No description provided for @fxpBass.
  ///
  /// In ru, this message translates to:
  /// **'Басы'**
  String get fxpBass;

  /// No description provided for @fxpTreble.
  ///
  /// In ru, this message translates to:
  /// **'Высокие'**
  String get fxpTreble;

  /// No description provided for @fxpFreq.
  ///
  /// In ru, this message translates to:
  /// **'Частота'**
  String get fxpFreq;

  /// No description provided for @fxpSlope.
  ///
  /// In ru, this message translates to:
  /// **'Крутизна'**
  String get fxpSlope;

  /// No description provided for @fxpOctaves.
  ///
  /// In ru, this message translates to:
  /// **'Ширина, октав'**
  String get fxpOctaves;

  /// No description provided for @fxpQ.
  ///
  /// In ru, this message translates to:
  /// **'Добротность (Q)'**
  String get fxpQ;

  /// No description provided for @fxpMains.
  ///
  /// In ru, this message translates to:
  /// **'Частота сети'**
  String get fxpMains;

  /// No description provided for @fxpHarmonics.
  ///
  /// In ru, this message translates to:
  /// **'Гармоник'**
  String get fxpHarmonics;

  /// No description provided for @fxpIntensity.
  ///
  /// In ru, this message translates to:
  /// **'Интенсивность'**
  String get fxpIntensity;

  /// No description provided for @fxpMaxReduction.
  ///
  /// In ru, this message translates to:
  /// **'Макс. подавление'**
  String get fxpMaxReduction;

  /// No description provided for @fxpFreqPos.
  ///
  /// In ru, this message translates to:
  /// **'Частота срабатывания'**
  String get fxpFreqPos;

  /// No description provided for @fxpAmount.
  ///
  /// In ru, this message translates to:
  /// **'Сила'**
  String get fxpAmount;

  /// No description provided for @fxpDrive.
  ///
  /// In ru, this message translates to:
  /// **'Драйв'**
  String get fxpDrive;

  /// No description provided for @fxpFloor.
  ///
  /// In ru, this message translates to:
  /// **'Уровень шума'**
  String get fxpFloor;

  /// No description provided for @fxpTrackNoise.
  ///
  /// In ru, this message translates to:
  /// **'Следить за изменением шума'**
  String get fxpTrackNoise;

  /// No description provided for @fxpStrength.
  ///
  /// In ru, this message translates to:
  /// **'Сила'**
  String get fxpStrength;

  /// No description provided for @fxpWindow.
  ///
  /// In ru, this message translates to:
  /// **'Окно'**
  String get fxpWindow;

  /// No description provided for @fxpSemitones.
  ///
  /// In ru, this message translates to:
  /// **'Сдвиг'**
  String get fxpSemitones;

  /// No description provided for @fxpFormants.
  ///
  /// In ru, this message translates to:
  /// **'Сохранять форманты (голос)'**
  String get fxpFormants;

  /// No description provided for @fxpHq.
  ///
  /// In ru, this message translates to:
  /// **'Высокое качество'**
  String get fxpHq;

  /// No description provided for @fxpPercent.
  ///
  /// In ru, this message translates to:
  /// **'Изменение'**
  String get fxpPercent;

  /// No description provided for @fxpStretch.
  ///
  /// In ru, this message translates to:
  /// **'Растяжение'**
  String get fxpStretch;

  /// No description provided for @fxpDelay.
  ///
  /// In ru, this message translates to:
  /// **'Задержка'**
  String get fxpDelay;

  /// No description provided for @fxpDecay.
  ///
  /// In ru, this message translates to:
  /// **'Затухание'**
  String get fxpDecay;

  /// No description provided for @fxpReverbTime.
  ///
  /// In ru, this message translates to:
  /// **'Время реверберации'**
  String get fxpReverbTime;

  /// No description provided for @fxpPredelay.
  ///
  /// In ru, this message translates to:
  /// **'Предзадержка'**
  String get fxpPredelay;

  /// No description provided for @fxpDamping.
  ///
  /// In ru, this message translates to:
  /// **'Демпфирование'**
  String get fxpDamping;

  /// No description provided for @fxpWet.
  ///
  /// In ru, this message translates to:
  /// **'Уровень эффекта'**
  String get fxpWet;

  /// No description provided for @fxpDry.
  ///
  /// In ru, this message translates to:
  /// **'Исходный звук'**
  String get fxpDry;

  /// No description provided for @fxpType.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get fxpType;

  /// No description provided for @fxpOutput.
  ///
  /// In ru, this message translates to:
  /// **'Выходной уровень'**
  String get fxpOutput;

  /// No description provided for @fxpBits.
  ///
  /// In ru, this message translates to:
  /// **'Разрядность'**
  String get fxpBits;

  /// No description provided for @fxpDownsample.
  ///
  /// In ru, this message translates to:
  /// **'Понижение частоты'**
  String get fxpDownsample;

  /// No description provided for @fxpMix.
  ///
  /// In ru, this message translates to:
  /// **'Смешивание'**
  String get fxpMix;

  /// No description provided for @fxpSpeed.
  ///
  /// In ru, this message translates to:
  /// **'Скорость'**
  String get fxpSpeed;

  /// No description provided for @fxpDepth.
  ///
  /// In ru, this message translates to:
  /// **'Глубина'**
  String get fxpDepth;

  /// No description provided for @fxpRegen.
  ///
  /// In ru, this message translates to:
  /// **'Обратная связь'**
  String get fxpRegen;

  /// No description provided for @fxpResonance.
  ///
  /// In ru, this message translates to:
  /// **'Резонанс'**
  String get fxpResonance;

  /// No description provided for @fxpOffset.
  ///
  /// In ru, this message translates to:
  /// **'Смещение частоты'**
  String get fxpOffset;

  /// No description provided for @fxpTimes.
  ///
  /// In ru, this message translates to:
  /// **'Число повторов'**
  String get fxpTimes;

  /// No description provided for @fxpMinSilence.
  ///
  /// In ru, this message translates to:
  /// **'Мин. длина тишины'**
  String get fxpMinSilence;

  /// No description provided for @fxpKeep.
  ///
  /// In ru, this message translates to:
  /// **'Оставить паузу'**
  String get fxpKeep;

  /// No description provided for @fxpKeepBass.
  ///
  /// In ru, this message translates to:
  /// **'Сохранять басы ниже'**
  String get fxpKeepBass;

  /// No description provided for @fxpLow.
  ///
  /// In ru, this message translates to:
  /// **'Нижняя граница'**
  String get fxpLow;

  /// No description provided for @fxpHigh.
  ///
  /// In ru, this message translates to:
  /// **'Верхняя граница'**
  String get fxpHigh;

  /// No description provided for @fxpBalance.
  ///
  /// In ru, this message translates to:
  /// **'Баланс'**
  String get fxpBalance;

  /// No description provided for @fxpWaveform.
  ///
  /// In ru, this message translates to:
  /// **'Форма волны'**
  String get fxpWaveform;

  /// No description provided for @fxpAmp.
  ///
  /// In ru, this message translates to:
  /// **'Амплитуда'**
  String get fxpAmp;

  /// No description provided for @fxpFreqStart.
  ///
  /// In ru, this message translates to:
  /// **'Начальная частота'**
  String get fxpFreqStart;

  /// No description provided for @fxpFreqEnd.
  ///
  /// In ru, this message translates to:
  /// **'Конечная частота'**
  String get fxpFreqEnd;

  /// No description provided for @fxpLog.
  ///
  /// In ru, this message translates to:
  /// **'Логарифмическая развёртка'**
  String get fxpLog;

  /// No description provided for @fxpColor.
  ///
  /// In ru, this message translates to:
  /// **'Цвет шума'**
  String get fxpColor;

  /// No description provided for @fxpBpm.
  ///
  /// In ru, this message translates to:
  /// **'Темп'**
  String get fxpBpm;

  /// No description provided for @fxpBeats.
  ///
  /// In ru, this message translates to:
  /// **'Долей в такте'**
  String get fxpBeats;

  /// No description provided for @fxpBandFreq.
  ///
  /// In ru, this message translates to:
  /// **'Полоса {n}: частота'**
  String fxpBandFreq(int n);

  /// No description provided for @fxpBandGain.
  ///
  /// In ru, this message translates to:
  /// **'Полоса {n}: усиление'**
  String fxpBandGain(int n);

  /// No description provided for @fxpBandQ.
  ///
  /// In ru, this message translates to:
  /// **'Полоса {n}: добротность'**
  String fxpBandQ(int n);

  /// No description provided for @curveLinear.
  ///
  /// In ru, this message translates to:
  /// **'линейная'**
  String get curveLinear;

  /// No description provided for @curveQsin.
  ///
  /// In ru, this message translates to:
  /// **'четверть синуса'**
  String get curveQsin;

  /// No description provided for @curveHsin.
  ///
  /// In ru, this message translates to:
  /// **'половина синуса'**
  String get curveHsin;

  /// No description provided for @curveEsin.
  ///
  /// In ru, this message translates to:
  /// **'экспонента синуса'**
  String get curveEsin;

  /// No description provided for @curveLog.
  ///
  /// In ru, this message translates to:
  /// **'логарифмическая'**
  String get curveLog;

  /// No description provided for @curveIpar.
  ///
  /// In ru, this message translates to:
  /// **'обратная парабола'**
  String get curveIpar;

  /// No description provided for @curveQua.
  ///
  /// In ru, this message translates to:
  /// **'квадратичная'**
  String get curveQua;

  /// No description provided for @curveCub.
  ///
  /// In ru, this message translates to:
  /// **'кубическая'**
  String get curveCub;

  /// No description provided for @curveSqu.
  ///
  /// In ru, this message translates to:
  /// **'квадратный корень'**
  String get curveSqu;

  /// No description provided for @curveCbr.
  ///
  /// In ru, this message translates to:
  /// **'кубический корень'**
  String get curveCbr;

  /// No description provided for @curvePar.
  ///
  /// In ru, this message translates to:
  /// **'парабола'**
  String get curvePar;

  /// No description provided for @curveExp.
  ///
  /// In ru, this message translates to:
  /// **'экспоненциальная'**
  String get curveExp;

  /// No description provided for @shapeLinear.
  ///
  /// In ru, this message translates to:
  /// **'линейная'**
  String get shapeLinear;

  /// No description provided for @shapeDb.
  ///
  /// In ru, this message translates to:
  /// **'в децибелах'**
  String get shapeDb;

  /// No description provided for @waveSine.
  ///
  /// In ru, this message translates to:
  /// **'синус'**
  String get waveSine;

  /// No description provided for @waveSquare.
  ///
  /// In ru, this message translates to:
  /// **'меандр'**
  String get waveSquare;

  /// No description provided for @waveSawtooth.
  ///
  /// In ru, this message translates to:
  /// **'пила'**
  String get waveSawtooth;

  /// No description provided for @waveTriangle.
  ///
  /// In ru, this message translates to:
  /// **'треугольник'**
  String get waveTriangle;

  /// No description provided for @noiseWhite.
  ///
  /// In ru, this message translates to:
  /// **'белый'**
  String get noiseWhite;

  /// No description provided for @noisePink.
  ///
  /// In ru, this message translates to:
  /// **'розовый'**
  String get noisePink;

  /// No description provided for @noiseBrown.
  ///
  /// In ru, this message translates to:
  /// **'коричневый'**
  String get noiseBrown;

  /// No description provided for @noiseBlue.
  ///
  /// In ru, this message translates to:
  /// **'синий'**
  String get noiseBlue;

  /// No description provided for @noiseViolet.
  ///
  /// In ru, this message translates to:
  /// **'фиолетовый'**
  String get noiseViolet;

  /// No description provided for @noiseVelvet.
  ///
  /// In ru, this message translates to:
  /// **'бархатный'**
  String get noiseVelvet;

  /// No description provided for @clipHard.
  ///
  /// In ru, this message translates to:
  /// **'жёсткое ограничение'**
  String get clipHard;

  /// No description provided for @clipTanh.
  ///
  /// In ru, this message translates to:
  /// **'гиперболический тангенс'**
  String get clipTanh;

  /// No description provided for @clipAtan.
  ///
  /// In ru, this message translates to:
  /// **'арктангенс'**
  String get clipAtan;

  /// No description provided for @clipCubic.
  ///
  /// In ru, this message translates to:
  /// **'кубическое'**
  String get clipCubic;

  /// No description provided for @clipExp.
  ///
  /// In ru, this message translates to:
  /// **'экспоненциальное'**
  String get clipExp;

  /// No description provided for @clipAlg.
  ///
  /// In ru, this message translates to:
  /// **'алгебраическое'**
  String get clipAlg;

  /// No description provided for @clipQuintic.
  ///
  /// In ru, this message translates to:
  /// **'пятой степени'**
  String get clipQuintic;

  /// No description provided for @clipSin.
  ///
  /// In ru, this message translates to:
  /// **'синусоидальное'**
  String get clipSin;

  /// No description provided for @clipErf.
  ///
  /// In ru, this message translates to:
  /// **'функция ошибок'**
  String get clipErf;

  /// No description provided for @genTone.
  ///
  /// In ru, this message translates to:
  /// **'Тон'**
  String get genTone;

  /// No description provided for @genChirp.
  ///
  /// In ru, this message translates to:
  /// **'Чирп (качающийся тон)'**
  String get genChirp;

  /// No description provided for @genNoise.
  ///
  /// In ru, this message translates to:
  /// **'Шум'**
  String get genNoise;

  /// No description provided for @genSilence.
  ///
  /// In ru, this message translates to:
  /// **'Тишина'**
  String get genSilence;

  /// No description provided for @genMetronome.
  ///
  /// In ru, this message translates to:
  /// **'Метроном'**
  String get genMetronome;

  /// No description provided for @genDtmf.
  ///
  /// In ru, this message translates to:
  /// **'Тоны DTMF'**
  String get genDtmf;

  /// No description provided for @off.
  ///
  /// In ru, this message translates to:
  /// **'выкл.'**
  String get off;

  /// No description provided for @vertical.
  ///
  /// In ru, this message translates to:
  /// **'вертикальное'**
  String get vertical;

  /// No description provided for @noAudioTag.
  ///
  /// In ru, this message translates to:
  /// **'без звука'**
  String get noAudioTag;

  /// No description provided for @addFiles.
  ///
  /// In ru, this message translates to:
  /// **'Добавить файлы'**
  String get addFiles;

  /// No description provided for @needMoreClips.
  ///
  /// In ru, this message translates to:
  /// **'Нужно хотя бы {n} файла'**
  String needMoreClips(int n);

  /// No description provided for @nothingChanged.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не изменено — задайте хотя бы один параметр'**
  String get nothingChanged;

  /// No description provided for @resultLength.
  ///
  /// In ru, this message translates to:
  /// **'Длительность результата: {d}'**
  String resultLength(String d);

  /// No description provided for @groupEditOutput.
  ///
  /// In ru, this message translates to:
  /// **'Результат'**
  String get groupEditOutput;

  /// No description provided for @pEditContainerHint.
  ///
  /// In ru, this message translates to:
  /// **'Формат файла результата'**
  String get pEditContainerHint;

  /// No description provided for @pEditQuality.
  ///
  /// In ru, this message translates to:
  /// **'Качество'**
  String get pEditQuality;

  /// No description provided for @pEditQualityHint.
  ///
  /// In ru, this message translates to:
  /// **'Видео перекодируется; звук копируется, если его не меняли'**
  String get pEditQualityHint;

  /// No description provided for @pEditQualityHelp.
  ///
  /// In ru, this message translates to:
  /// **'«Высокое» — практически без видимых потерь (для x264 это CRF 18), файл крупнее. «Обычное» — значение кодировщика по умолчанию (CRF 23). «Меньше размер» — заметно меньше файл, мелкие детали могут смазаться (CRF 28). Кодек выбирается как у исходника, если формат его поддерживает.'**
  String get pEditQualityHelp;

  /// No description provided for @editQualityHigh.
  ///
  /// In ru, this message translates to:
  /// **'Высокое'**
  String get editQualityHigh;

  /// No description provided for @editQualityBalanced.
  ///
  /// In ru, this message translates to:
  /// **'Обычное'**
  String get editQualityBalanced;

  /// No description provided for @editQualitySmall.
  ///
  /// In ru, this message translates to:
  /// **'Меньше размер'**
  String get editQualitySmall;

  /// No description provided for @pEditSpeedHint.
  ///
  /// In ru, this message translates to:
  /// **'Быстрее — крупнее файл при том же качестве'**
  String get pEditSpeedHint;

  /// No description provided for @previewBefore.
  ///
  /// In ru, this message translates to:
  /// **'До'**
  String get previewBefore;

  /// No description provided for @previewSplit.
  ///
  /// In ru, this message translates to:
  /// **'Шторка'**
  String get previewSplit;

  /// No description provided for @previewAfter.
  ///
  /// In ru, this message translates to:
  /// **'После'**
  String get previewAfter;

  /// No description provided for @rectHintOne.
  ///
  /// In ru, this message translates to:
  /// **'Выделите область мышью; тяните за угол, чтобы изменить размер'**
  String get rectHintOne;

  /// No description provided for @rectHintMany.
  ///
  /// In ru, this message translates to:
  /// **'Рисуйте области мышью (до 12); перетаскивайте их и тяните за угол'**
  String get rectHintMany;

  /// No description provided for @groupFragments.
  ///
  /// In ru, this message translates to:
  /// **'Фрагменты'**
  String get groupFragments;

  /// No description provided for @pCutMode.
  ///
  /// In ru, this message translates to:
  /// **'Что делать с отмеченным'**
  String get pCutMode;

  /// No description provided for @cutModeRemove.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get cutModeRemove;

  /// No description provided for @cutModeKeep.
  ///
  /// In ru, this message translates to:
  /// **'Оставить только их'**
  String get cutModeKeep;

  /// No description provided for @cutModeRemoveHint.
  ///
  /// In ru, this message translates to:
  /// **'Отмеченные куски вырезаются, остальное склеивается'**
  String get cutModeRemoveHint;

  /// No description provided for @cutModeKeepHint.
  ///
  /// In ru, this message translates to:
  /// **'Остаются только отмеченные куски, в порядке времени'**
  String get cutModeKeepHint;

  /// No description provided for @cutHowTo.
  ///
  /// In ru, this message translates to:
  /// **'Найдите место в плеере и нажмите «Начало», затем «Конец». Можно отметить сколько угодно фрагментов.'**
  String get cutHowTo;

  /// No description provided for @markFragmentStart.
  ///
  /// In ru, this message translates to:
  /// **'Начало: {t}'**
  String markFragmentStart(String t);

  /// No description provided for @markFragmentEnd.
  ///
  /// In ru, this message translates to:
  /// **'Конец: {t}'**
  String markFragmentEnd(String t);

  /// No description provided for @playFragment.
  ///
  /// In ru, this message translates to:
  /// **'Воспроизвести фрагмент'**
  String get playFragment;

  /// No description provided for @cutNoRanges.
  ///
  /// In ru, this message translates to:
  /// **'Отметьте хотя бы один фрагмент'**
  String get cutNoRanges;

  /// No description provided for @cutNothingLeft.
  ///
  /// In ru, this message translates to:
  /// **'После удаления ничего не остаётся'**
  String get cutNothingLeft;

  /// No description provided for @pLosslessCut.
  ///
  /// In ru, this message translates to:
  /// **'Без перекодирования'**
  String get pLosslessCut;

  /// No description provided for @losslessCutOnHint.
  ///
  /// In ru, this message translates to:
  /// **'Мгновенно и без потерь, но границы — по ближайшим ключевым кадрам'**
  String get losslessCutOnHint;

  /// No description provided for @losslessCutOffHint.
  ///
  /// In ru, this message translates to:
  /// **'Точно до кадра; видео перекодируется'**
  String get losslessCutOffHint;

  /// No description provided for @pLosslessCutHelp.
  ///
  /// In ru, this message translates to:
  /// **'Видео сжато группами кадров, и начать кусок без перекодирования можно только с ключевого кадра (обычно они идут раз в 1–10 секунд). Поэтому в быстром режиме фрагмент может начаться чуть раньше отмеченного места. Если нужна точность до кадра — выключите этот режим: файл перекодируется, это дольше.'**
  String get pLosslessCutHelp;

  /// No description provided for @groupClips.
  ///
  /// In ru, this message translates to:
  /// **'Файлы'**
  String get groupClips;

  /// No description provided for @groupJoin.
  ///
  /// In ru, this message translates to:
  /// **'Склейка'**
  String get groupJoin;

  /// No description provided for @pLosslessJoin.
  ///
  /// In ru, this message translates to:
  /// **'Без перекодирования'**
  String get pLosslessJoin;

  /// No description provided for @losslessJoinOnHint.
  ///
  /// In ru, this message translates to:
  /// **'Мгновенно; файлы должны быть одинаковыми по кодеку и размеру'**
  String get losslessJoinOnHint;

  /// No description provided for @losslessJoinOffHint.
  ///
  /// In ru, this message translates to:
  /// **'Любые файлы: приводятся к одному размеру и частоте кадров'**
  String get losslessJoinOffHint;

  /// No description provided for @pLosslessJoinHelp.
  ///
  /// In ru, this message translates to:
  /// **'Склейка без перекодирования подходит для частей одной записи (с одной камеры, одного стрима). Если у файлов разные кодеки, разрешение или параметры звука, результат может не воспроизводиться — тогда выключите этот режим.'**
  String get pLosslessJoinHelp;

  /// No description provided for @concatMismatch.
  ///
  /// In ru, this message translates to:
  /// **'Файлы различаются: {what}. Без перекодирования результат может не воспроизводиться.'**
  String concatMismatch(String what);

  /// No description provided for @mismatchCodec.
  ///
  /// In ru, this message translates to:
  /// **'кодек видео'**
  String get mismatchCodec;

  /// No description provided for @mismatchSize.
  ///
  /// In ru, this message translates to:
  /// **'разрешение'**
  String get mismatchSize;

  /// No description provided for @mismatchPixfmt.
  ///
  /// In ru, this message translates to:
  /// **'формат пикселей'**
  String get mismatchPixfmt;

  /// No description provided for @mismatchAudio.
  ///
  /// In ru, this message translates to:
  /// **'наличие звука'**
  String get mismatchAudio;

  /// No description provided for @mismatchAudioCodec.
  ///
  /// In ru, this message translates to:
  /// **'формат звука'**
  String get mismatchAudioCodec;

  /// No description provided for @mismatchVideo.
  ///
  /// In ru, this message translates to:
  /// **'наличие видео'**
  String get mismatchVideo;

  /// No description provided for @groupFrame.
  ///
  /// In ru, this message translates to:
  /// **'Кадр'**
  String get groupFrame;

  /// No description provided for @pJoinSize.
  ///
  /// In ru, this message translates to:
  /// **'Размер кадра'**
  String get pJoinSize;

  /// No description provided for @pJoinSizeHint.
  ///
  /// In ru, this message translates to:
  /// **'Остальные файлы вписываются с полями'**
  String get pJoinSizeHint;

  /// No description provided for @joinSizeFirst.
  ///
  /// In ru, this message translates to:
  /// **'Как у первого ({size})'**
  String joinSizeFirst(String size);

  /// No description provided for @groupTransition.
  ///
  /// In ru, this message translates to:
  /// **'Переход между файлами'**
  String get groupTransition;

  /// No description provided for @pTransition.
  ///
  /// In ru, this message translates to:
  /// **'Эффект'**
  String get pTransition;

  /// No description provided for @pTransitionHint.
  ///
  /// In ru, this message translates to:
  /// **'Как один файл сменяет другой'**
  String get pTransitionHint;

  /// No description provided for @pTransitionDuration.
  ///
  /// In ru, this message translates to:
  /// **'Длительность перехода'**
  String get pTransitionDuration;

  /// No description provided for @pTransitionDurationHint.
  ///
  /// In ru, this message translates to:
  /// **'Файлы перекрываются на это время'**
  String get pTransitionDurationHint;

  /// No description provided for @clipShorterThanTransition.
  ///
  /// In ru, this message translates to:
  /// **'Какой-то файл короче двух переходов — уменьшите длительность перехода'**
  String get clipShorterThanTransition;

  /// No description provided for @groupFades.
  ///
  /// In ru, this message translates to:
  /// **'Появление и исчезание'**
  String get groupFades;

  /// No description provided for @pFadeIn.
  ///
  /// In ru, this message translates to:
  /// **'Появление из чёрного'**
  String get pFadeIn;

  /// No description provided for @pFadeInHint.
  ///
  /// In ru, this message translates to:
  /// **'В начале; звук нарастает вместе с картинкой'**
  String get pFadeInHint;

  /// No description provided for @pFadeOut.
  ///
  /// In ru, this message translates to:
  /// **'Уход в чёрное'**
  String get pFadeOut;

  /// No description provided for @pFadeOutHint.
  ///
  /// In ru, this message translates to:
  /// **'В конце; звук затихает вместе с картинкой'**
  String get pFadeOutHint;

  /// No description provided for @xfFade.
  ///
  /// In ru, this message translates to:
  /// **'Растворение'**
  String get xfFade;

  /// No description provided for @xfDissolve.
  ///
  /// In ru, this message translates to:
  /// **'Рассыпание'**
  String get xfDissolve;

  /// No description provided for @xfFadeBlack.
  ///
  /// In ru, this message translates to:
  /// **'Через чёрный'**
  String get xfFadeBlack;

  /// No description provided for @xfFadeWhite.
  ///
  /// In ru, this message translates to:
  /// **'Через белый'**
  String get xfFadeWhite;

  /// No description provided for @xfCircleOpen.
  ///
  /// In ru, this message translates to:
  /// **'Круг раскрывается'**
  String get xfCircleOpen;

  /// No description provided for @xfCircleClose.
  ///
  /// In ru, this message translates to:
  /// **'Круг закрывается'**
  String get xfCircleClose;

  /// No description provided for @xfCircleCrop.
  ///
  /// In ru, this message translates to:
  /// **'Круглая шторка'**
  String get xfCircleCrop;

  /// No description provided for @xfRectCrop.
  ///
  /// In ru, this message translates to:
  /// **'Прямоугольная шторка'**
  String get xfRectCrop;

  /// No description provided for @xfRadial.
  ///
  /// In ru, this message translates to:
  /// **'Радиальная стрелка'**
  String get xfRadial;

  /// No description provided for @xfPixelize.
  ///
  /// In ru, this message translates to:
  /// **'Пикселизация'**
  String get xfPixelize;

  /// No description provided for @xfDistance.
  ///
  /// In ru, this message translates to:
  /// **'Перетекание'**
  String get xfDistance;

  /// No description provided for @xfBlur.
  ///
  /// In ru, this message translates to:
  /// **'Размытие'**
  String get xfBlur;

  /// No description provided for @xfZoom.
  ///
  /// In ru, this message translates to:
  /// **'Наезд'**
  String get xfZoom;

  /// No description provided for @xfWipe.
  ///
  /// In ru, this message translates to:
  /// **'Шторка {dir}'**
  String xfWipe(String dir);

  /// No description provided for @xfSlide.
  ///
  /// In ru, this message translates to:
  /// **'Сдвиг {dir}'**
  String xfSlide(String dir);

  /// No description provided for @xfSmooth.
  ///
  /// In ru, this message translates to:
  /// **'Плавная шторка {dir}'**
  String xfSmooth(String dir);

  /// No description provided for @xfDiagonal.
  ///
  /// In ru, this message translates to:
  /// **'Диагональ {dir}'**
  String xfDiagonal(String dir);

  /// No description provided for @xfSqueeze.
  ///
  /// In ru, this message translates to:
  /// **'Сжатие {dir}'**
  String xfSqueeze(String dir);

  /// No description provided for @xfOpen.
  ///
  /// In ru, this message translates to:
  /// **'Раскрытие {dir}'**
  String xfOpen(String dir);

  /// No description provided for @groupSplit.
  ///
  /// In ru, this message translates to:
  /// **'Разделение'**
  String get groupSplit;

  /// No description provided for @pSplitMode.
  ///
  /// In ru, this message translates to:
  /// **'Как делить'**
  String get pSplitMode;

  /// No description provided for @pSplitModeHint.
  ///
  /// In ru, this message translates to:
  /// **'Части сохраняются как имя_001, имя_002…'**
  String get pSplitModeHint;

  /// No description provided for @splitEvery.
  ///
  /// In ru, this message translates to:
  /// **'По времени'**
  String get splitEvery;

  /// No description provided for @splitParts.
  ///
  /// In ru, this message translates to:
  /// **'На N частей'**
  String get splitParts;

  /// No description provided for @splitChapters.
  ///
  /// In ru, this message translates to:
  /// **'По главам'**
  String get splitChapters;

  /// No description provided for @splitTimes.
  ///
  /// In ru, this message translates to:
  /// **'По меткам'**
  String get splitTimes;

  /// No description provided for @pSplitEvery.
  ///
  /// In ru, this message translates to:
  /// **'Длина части'**
  String get pSplitEvery;

  /// No description provided for @pSplitParts.
  ///
  /// In ru, this message translates to:
  /// **'Число частей'**
  String get pSplitParts;

  /// No description provided for @pSplitPartsHint.
  ///
  /// In ru, this message translates to:
  /// **'Равные по длительности'**
  String get pSplitPartsHint;

  /// No description provided for @addCutPoint.
  ///
  /// In ru, this message translates to:
  /// **'Разрезать здесь: {t}'**
  String addCutPoint(String t);

  /// No description provided for @splitNoPoints.
  ///
  /// In ru, this message translates to:
  /// **'Нет точек разреза'**
  String get splitNoPoints;

  /// No description provided for @splitFiles.
  ///
  /// In ru, this message translates to:
  /// **'Получится файлов: {n}'**
  String splitFiles(int n);

  /// No description provided for @pSplitPrecise.
  ///
  /// In ru, this message translates to:
  /// **'Точно до кадра'**
  String get pSplitPrecise;

  /// No description provided for @splitPreciseOnHint.
  ///
  /// In ru, this message translates to:
  /// **'Видео перекодируется, разрезы ровно в заданных местах'**
  String get splitPreciseOnHint;

  /// No description provided for @splitPreciseOffHint.
  ///
  /// In ru, this message translates to:
  /// **'Мгновенно и без потерь; разрезы по ближайшим ключевым кадрам'**
  String get splitPreciseOffHint;

  /// No description provided for @splitKeyframeNote.
  ///
  /// In ru, this message translates to:
  /// **'Без перекодирования части начинаются с ключевых кадров, поэтому их длина может немного отличаться.'**
  String get splitKeyframeNote;

  /// No description provided for @groupCrop.
  ///
  /// In ru, this message translates to:
  /// **'Кадрирование'**
  String get groupCrop;

  /// No description provided for @pCropEdit.
  ///
  /// In ru, this message translates to:
  /// **'Выделить область'**
  String get pCropEdit;

  /// No description provided for @pCropEditHint.
  ///
  /// In ru, this message translates to:
  /// **'Включите и обведите на кадре то, что нужно оставить'**
  String get pCropEditHint;

  /// No description provided for @cropRectLabel.
  ///
  /// In ru, this message translates to:
  /// **'{size} от точки {x}, {y}'**
  String cropRectLabel(String size, String x, String y);

  /// No description provided for @cropAutodetect.
  ///
  /// In ru, this message translates to:
  /// **'Найти чёрные поля'**
  String get cropAutodetect;

  /// No description provided for @cropReset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get cropReset;

  /// No description provided for @cropNothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Чёрных полей не найдено'**
  String get cropNothingFound;

  /// No description provided for @groupRotate.
  ///
  /// In ru, this message translates to:
  /// **'Поворот и отражение'**
  String get groupRotate;

  /// No description provided for @pRotate.
  ///
  /// In ru, this message translates to:
  /// **'Повернуть'**
  String get pRotate;

  /// No description provided for @pRotateHint.
  ///
  /// In ru, this message translates to:
  /// **'По часовой стрелке'**
  String get pRotateHint;

  /// No description provided for @pFlipH.
  ///
  /// In ru, this message translates to:
  /// **'Отразить по горизонтали'**
  String get pFlipH;

  /// No description provided for @pFlipHHint.
  ///
  /// In ru, this message translates to:
  /// **'Зеркально: левое становится правым'**
  String get pFlipHHint;

  /// No description provided for @pFlipV.
  ///
  /// In ru, this message translates to:
  /// **'Отразить по вертикали'**
  String get pFlipV;

  /// No description provided for @pFlipVHint.
  ///
  /// In ru, this message translates to:
  /// **'Верх становится низом'**
  String get pFlipVHint;

  /// No description provided for @pAngle.
  ///
  /// In ru, this message translates to:
  /// **'Наклон'**
  String get pAngle;

  /// No description provided for @pAngleHint.
  ///
  /// In ru, this message translates to:
  /// **'Выровнять заваленный горизонт; края заполняются чёрным'**
  String get pAngleHint;

  /// No description provided for @makeVertical.
  ///
  /// In ru, this message translates to:
  /// **'Вертикальное 9:16'**
  String get makeVertical;

  /// No description provided for @pAspect.
  ///
  /// In ru, this message translates to:
  /// **'Пропорции кадра'**
  String get pAspect;

  /// No description provided for @pAspectHint.
  ///
  /// In ru, this message translates to:
  /// **'9:16 — Shorts, Reels, TikTok; 1:1 и 4:5 — лента'**
  String get pAspectHint;

  /// No description provided for @pFrameHeight.
  ///
  /// In ru, this message translates to:
  /// **'Высота кадра'**
  String get pFrameHeight;

  /// No description provided for @pFrameHeightHint.
  ///
  /// In ru, this message translates to:
  /// **'Ширина считается по пропорциям'**
  String get pFrameHeightHint;

  /// No description provided for @pFit.
  ///
  /// In ru, this message translates to:
  /// **'Как вписать'**
  String get pFit;

  /// No description provided for @fitFit.
  ///
  /// In ru, this message translates to:
  /// **'С полями'**
  String get fitFit;

  /// No description provided for @fitFill.
  ///
  /// In ru, this message translates to:
  /// **'Заполнить'**
  String get fitFill;

  /// No description provided for @fitBlur.
  ///
  /// In ru, this message translates to:
  /// **'Размытый фон'**
  String get fitBlur;

  /// No description provided for @fitStretch.
  ///
  /// In ru, this message translates to:
  /// **'Растянуть'**
  String get fitStretch;

  /// No description provided for @fitFitHint.
  ///
  /// In ru, this message translates to:
  /// **'Видна вся картинка, по краям чёрные полосы'**
  String get fitFitHint;

  /// No description provided for @fitFillHint.
  ///
  /// In ru, this message translates to:
  /// **'Кадр заполнен, края картинки обрезаются'**
  String get fitFillHint;

  /// No description provided for @fitBlurHint.
  ///
  /// In ru, this message translates to:
  /// **'Вся картинка поверх её же размытой копии — как в соцсетях'**
  String get fitBlurHint;

  /// No description provided for @fitStretchHint.
  ///
  /// In ru, this message translates to:
  /// **'Картинка искажается под новый кадр'**
  String get fitStretchHint;

  /// No description provided for @frameSizeResult.
  ///
  /// In ru, this message translates to:
  /// **'Кадр: {from} → {to}'**
  String frameSizeResult(String from, String to);

  /// No description provided for @groupSpeed.
  ///
  /// In ru, this message translates to:
  /// **'Скорость'**
  String get groupSpeed;

  /// No description provided for @pSpeedFactor.
  ///
  /// In ru, this message translates to:
  /// **'Множитель'**
  String get pSpeedFactor;

  /// No description provided for @pSpeedFactorHint.
  ///
  /// In ru, this message translates to:
  /// **'Больше 1 — быстрее, меньше 1 — замедление'**
  String get pSpeedFactorHint;

  /// No description provided for @pSpeedAudio.
  ///
  /// In ru, this message translates to:
  /// **'Звук'**
  String get pSpeedAudio;

  /// No description provided for @speedAudioKeep.
  ///
  /// In ru, this message translates to:
  /// **'Тот же тон'**
  String get speedAudioKeep;

  /// No description provided for @speedAudioPitch.
  ///
  /// In ru, this message translates to:
  /// **'Как пластинка'**
  String get speedAudioPitch;

  /// No description provided for @speedAudioMute.
  ///
  /// In ru, this message translates to:
  /// **'Убрать'**
  String get speedAudioMute;

  /// No description provided for @speedAudioKeepHint.
  ///
  /// In ru, this message translates to:
  /// **'Темп меняется, голос не становится выше или ниже'**
  String get speedAudioKeepHint;

  /// No description provided for @speedAudioPitchHint.
  ///
  /// In ru, this message translates to:
  /// **'Ускорение повышает тон, замедление понижает'**
  String get speedAudioPitchHint;

  /// No description provided for @speedAudioMuteHint.
  ///
  /// In ru, this message translates to:
  /// **'В результате не будет звука'**
  String get speedAudioMuteHint;

  /// No description provided for @pReverse.
  ///
  /// In ru, this message translates to:
  /// **'Задом наперёд'**
  String get pReverse;

  /// No description provided for @pReverseHint.
  ///
  /// In ru, this message translates to:
  /// **'Видео и звук проигрываются в обратную сторону'**
  String get pReverseHint;

  /// No description provided for @groupFrameRate.
  ///
  /// In ru, this message translates to:
  /// **'Частота кадров'**
  String get groupFrameRate;

  /// No description provided for @pSpeedFps.
  ///
  /// In ru, this message translates to:
  /// **'Кадров в секунду'**
  String get pSpeedFps;

  /// No description provided for @pSpeedFpsHint.
  ///
  /// In ru, this message translates to:
  /// **'У исходника {fps}'**
  String pSpeedFpsHint(String fps);

  /// No description provided for @pInterpolate.
  ///
  /// In ru, this message translates to:
  /// **'Плавное движение'**
  String get pInterpolate;

  /// No description provided for @pInterpolateHint.
  ///
  /// In ru, this message translates to:
  /// **'Дорисовывает промежуточные кадры (для замедления)'**
  String get pInterpolateHint;

  /// No description provided for @pInterpolateHelp.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр minterpolate вычисляет движение и создаёт новые кадры между существующими. Замедление выглядит плавным, а не дёрганым. Работает очень медленно и на быстрых сценах может давать артефакты.'**
  String get pInterpolateHelp;

  /// No description provided for @reverseMemoryWarning.
  ///
  /// In ru, this message translates to:
  /// **'Обратное воспроизведение держит в памяти весь фрагмент: на длинных файлах может не хватить оперативной памяти. Лучше сначала вырезать короткий кусок.'**
  String get reverseMemoryWarning;

  /// No description provided for @interpolateSlowWarning.
  ///
  /// In ru, this message translates to:
  /// **'Плавное движение работает очень медленно — минута видео может считаться десятки минут.'**
  String get interpolateSlowWarning;

  /// No description provided for @atempoQualityNote.
  ///
  /// In ru, this message translates to:
  /// **'При сильном изменении темпа звук с сохранением тона может звучать «металлически».'**
  String get atempoQualityNote;

  /// No description provided for @groupRestore.
  ///
  /// In ru, this message translates to:
  /// **'Восстановление'**
  String get groupRestore;

  /// No description provided for @pDeinterlace.
  ///
  /// In ru, this message translates to:
  /// **'Убрать «гребёнку»'**
  String get pDeinterlace;

  /// No description provided for @pDeinterlaceHint.
  ///
  /// In ru, this message translates to:
  /// **'Для записей с ТВ, видеокассет, старых камер'**
  String get pDeinterlaceHint;

  /// No description provided for @deinterlaceDetected.
  ///
  /// In ru, this message translates to:
  /// **'Файл чересстрочный — рекомендуется включить'**
  String get deinterlaceDetected;

  /// No description provided for @pDeinterlaceHelp.
  ///
  /// In ru, this message translates to:
  /// **'Чересстрочное видео показывает полукадры, и на движении видны горизонтальные полосы («гребёнка»). bwdif — современный качественный фильтр; yadif — классический, чуть быстрее.'**
  String get pDeinterlaceHelp;

  /// No description provided for @pVideoDenoise.
  ///
  /// In ru, this message translates to:
  /// **'Подавление шума'**
  String get pVideoDenoise;

  /// No description provided for @pVideoDenoiseHint.
  ///
  /// In ru, this message translates to:
  /// **'Убирает зерно и цифровой шум'**
  String get pVideoDenoiseHint;

  /// No description provided for @pVideoDenoiseHelp.
  ///
  /// In ru, this message translates to:
  /// **'Слабое–сильное — быстрый фильтр hqdn3d: чем сильнее, тем чище, но картинка становится «пластиковой». NLMeans — заметно качественнее сохраняет детали, но работает в десятки раз медленнее.'**
  String get pVideoDenoiseHelp;

  /// No description provided for @levelLight.
  ///
  /// In ru, this message translates to:
  /// **'Слабое'**
  String get levelLight;

  /// No description provided for @levelMedium.
  ///
  /// In ru, this message translates to:
  /// **'Среднее'**
  String get levelMedium;

  /// No description provided for @levelStrong.
  ///
  /// In ru, this message translates to:
  /// **'Сильное'**
  String get levelStrong;

  /// No description provided for @denoiseNlmeans.
  ///
  /// In ru, this message translates to:
  /// **'NLMeans (качественно, медленно)'**
  String get denoiseNlmeans;

  /// No description provided for @pSharpen.
  ///
  /// In ru, this message translates to:
  /// **'Резкость'**
  String get pSharpen;

  /// No description provided for @pSharpenHint.
  ///
  /// In ru, this message translates to:
  /// **'Подчёркивает детали; не делает размытое чётким'**
  String get pSharpenHint;

  /// No description provided for @sharpenCas.
  ///
  /// In ru, this message translates to:
  /// **'Адаптивная (CAS)'**
  String get sharpenCas;

  /// No description provided for @groupStabilize.
  ///
  /// In ru, this message translates to:
  /// **'Стабилизация'**
  String get groupStabilize;

  /// No description provided for @pStabilize.
  ///
  /// In ru, this message translates to:
  /// **'Убрать тряску'**
  String get pStabilize;

  /// No description provided for @pStabilizeHint.
  ///
  /// In ru, this message translates to:
  /// **'Два прохода: анализ движения, затем выравнивание'**
  String get pStabilizeHint;

  /// No description provided for @pStabilizeDeshakeHint.
  ///
  /// In ru, this message translates to:
  /// **'В этой сборке нет vidstab — будет простой фильтр deshake'**
  String get pStabilizeDeshakeHint;

  /// No description provided for @pStabilizeHelp.
  ///
  /// In ru, this message translates to:
  /// **'Сначала программа отслеживает движение камеры по всему файлу, затем сдвигает и слегка увеличивает кадры, чтобы скрыть дрожание. Края кадра при этом немного обрезаются. Предпросмотр стабилизацию не показывает — её видно только в результате.'**
  String get pStabilizeHelp;

  /// No description provided for @pShakiness.
  ///
  /// In ru, this message translates to:
  /// **'Сила тряски'**
  String get pShakiness;

  /// No description provided for @pShakinessHint.
  ///
  /// In ru, this message translates to:
  /// **'Насколько сильно трясётся исходник (1–10)'**
  String get pShakinessHint;

  /// No description provided for @pSmoothing.
  ///
  /// In ru, this message translates to:
  /// **'Сглаживание'**
  String get pSmoothing;

  /// No description provided for @pSmoothingHint.
  ///
  /// In ru, this message translates to:
  /// **'Больше — плавнее, но сильнее обрезка краёв'**
  String get pSmoothingHint;

  /// No description provided for @vidstabMissing.
  ///
  /// In ru, this message translates to:
  /// **'В этой сборке ffmpeg нет libvidstab — используется более простой фильтр deshake. Для качественной стабилизации установите полную сборку в «Компонентах».'**
  String get vidstabMissing;

  /// No description provided for @nlmeansSlowWarning.
  ///
  /// In ru, this message translates to:
  /// **'NLMeans очень медленный: на Full HD — около кадра в секунду.'**
  String get nlmeansSlowWarning;

  /// No description provided for @stepAnalyzeMotion.
  ///
  /// In ru, this message translates to:
  /// **'анализ движения'**
  String get stepAnalyzeMotion;

  /// No description provided for @groupColorBasic.
  ///
  /// In ru, this message translates to:
  /// **'Основное'**
  String get groupColorBasic;

  /// No description provided for @pBrightness.
  ///
  /// In ru, this message translates to:
  /// **'Яркость'**
  String get pBrightness;

  /// No description provided for @pBrightnessHint.
  ///
  /// In ru, this message translates to:
  /// **'0 — без изменений'**
  String get pBrightnessHint;

  /// No description provided for @pContrast.
  ///
  /// In ru, this message translates to:
  /// **'Контраст'**
  String get pContrast;

  /// No description provided for @pContrastHint.
  ///
  /// In ru, this message translates to:
  /// **'1 — без изменений'**
  String get pContrastHint;

  /// No description provided for @pSaturation.
  ///
  /// In ru, this message translates to:
  /// **'Насыщенность'**
  String get pSaturation;

  /// No description provided for @pSaturationHint.
  ///
  /// In ru, this message translates to:
  /// **'0 — чёрно-белое, 1 — без изменений'**
  String get pSaturationHint;

  /// No description provided for @pGamma.
  ///
  /// In ru, this message translates to:
  /// **'Гамма'**
  String get pGamma;

  /// No description provided for @pGammaHint.
  ///
  /// In ru, this message translates to:
  /// **'Осветляет или затемняет средние тона'**
  String get pGammaHint;

  /// No description provided for @pHue.
  ///
  /// In ru, this message translates to:
  /// **'Оттенок'**
  String get pHue;

  /// No description provided for @pHueHint.
  ///
  /// In ru, this message translates to:
  /// **'Сдвиг всех цветов по цветовому кругу'**
  String get pHueHint;

  /// No description provided for @pTemperature.
  ///
  /// In ru, this message translates to:
  /// **'Цветовая температура'**
  String get pTemperature;

  /// No description provided for @pTemperatureHint.
  ///
  /// In ru, this message translates to:
  /// **'Меньше — теплее (желтее), больше — холоднее (синее); 6500 K — нейтрально'**
  String get pTemperatureHint;

  /// No description provided for @groupLook.
  ///
  /// In ru, this message translates to:
  /// **'Стиль'**
  String get groupLook;

  /// No description provided for @pLook.
  ///
  /// In ru, this message translates to:
  /// **'Готовый стиль'**
  String get pLook;

  /// No description provided for @pLookHint.
  ///
  /// In ru, this message translates to:
  /// **'Применяется после основных настроек'**
  String get pLookHint;

  /// No description provided for @lookGrayscale.
  ///
  /// In ru, this message translates to:
  /// **'Чёрно-белое'**
  String get lookGrayscale;

  /// No description provided for @lookSepia.
  ///
  /// In ru, this message translates to:
  /// **'Сепия'**
  String get lookSepia;

  /// No description provided for @lookVintage.
  ///
  /// In ru, this message translates to:
  /// **'Винтаж'**
  String get lookVintage;

  /// No description provided for @lookCrossProcess.
  ///
  /// In ru, this message translates to:
  /// **'Кросс-процесс'**
  String get lookCrossProcess;

  /// No description provided for @lookNegative.
  ///
  /// In ru, this message translates to:
  /// **'Негатив'**
  String get lookNegative;

  /// No description provided for @lookStrongContrast.
  ///
  /// In ru, this message translates to:
  /// **'Сильный контраст'**
  String get lookStrongContrast;

  /// No description provided for @lookLighter.
  ///
  /// In ru, this message translates to:
  /// **'Светлее'**
  String get lookLighter;

  /// No description provided for @lookDarker.
  ///
  /// In ru, this message translates to:
  /// **'Темнее'**
  String get lookDarker;

  /// No description provided for @pVignette.
  ///
  /// In ru, this message translates to:
  /// **'Виньетка'**
  String get pVignette;

  /// No description provided for @pVignetteHint.
  ///
  /// In ru, this message translates to:
  /// **'Затемнение по краям кадра'**
  String get pVignetteHint;

  /// No description provided for @pLut.
  ///
  /// In ru, this message translates to:
  /// **'LUT-файл'**
  String get pLut;

  /// No description provided for @pLutHint.
  ///
  /// In ru, this message translates to:
  /// **'.cube или .3dl — готовая цветокоррекция'**
  String get pLutHint;

  /// No description provided for @pLutHelp.
  ///
  /// In ru, this message translates to:
  /// **'LUT (таблица преобразования цвета) — файл с готовой цветокоррекцией из DaVinci Resolve, Premiere или от производителя камеры (например, перевод Log-профиля в обычный вид). Применяется до остальных настроек.'**
  String get pLutHelp;

  /// No description provided for @pLutMix.
  ///
  /// In ru, this message translates to:
  /// **'Сила LUT'**
  String get pLutMix;

  /// No description provided for @pLutMixHint.
  ///
  /// In ru, this message translates to:
  /// **'Смешивание с исходными цветами'**
  String get pLutMixHint;

  /// No description provided for @groupWatermark.
  ///
  /// In ru, this message translates to:
  /// **'Логотип'**
  String get groupWatermark;

  /// No description provided for @pWatermarkImage.
  ///
  /// In ru, this message translates to:
  /// **'Картинка'**
  String get pWatermarkImage;

  /// No description provided for @pWatermarkImageHint.
  ///
  /// In ru, this message translates to:
  /// **'PNG с прозрачностью подходит лучше всего'**
  String get pWatermarkImageHint;

  /// No description provided for @pPosition.
  ///
  /// In ru, this message translates to:
  /// **'Положение'**
  String get pPosition;

  /// No description provided for @pPositionHint.
  ///
  /// In ru, this message translates to:
  /// **'Угол или край кадра'**
  String get pPositionHint;

  /// No description provided for @pWatermarkSize.
  ///
  /// In ru, this message translates to:
  /// **'Размер'**
  String get pWatermarkSize;

  /// No description provided for @pWatermarkSizeHint.
  ///
  /// In ru, this message translates to:
  /// **'Ширина относительно ширины видео'**
  String get pWatermarkSizeHint;

  /// No description provided for @pOpacity.
  ///
  /// In ru, this message translates to:
  /// **'Непрозрачность'**
  String get pOpacity;

  /// No description provided for @pOpacityHint.
  ///
  /// In ru, this message translates to:
  /// **'Меньше — прозрачнее'**
  String get pOpacityHint;

  /// No description provided for @groupText.
  ///
  /// In ru, this message translates to:
  /// **'Текст'**
  String get groupText;

  /// No description provided for @pOverlayText.
  ///
  /// In ru, this message translates to:
  /// **'Надпись'**
  String get pOverlayText;

  /// No description provided for @pOverlayTextHint.
  ///
  /// In ru, this message translates to:
  /// **'Любой текст, включая символы % : , \' [ ]'**
  String get pOverlayTextHint;

  /// No description provided for @pFontSize.
  ///
  /// In ru, this message translates to:
  /// **'Размер шрифта'**
  String get pFontSize;

  /// No description provided for @pFontSizeHint.
  ///
  /// In ru, this message translates to:
  /// **'Относительно высоты видео'**
  String get pFontSizeHint;

  /// No description provided for @pFontColor.
  ///
  /// In ru, this message translates to:
  /// **'Цвет'**
  String get pFontColor;

  /// No description provided for @pFontColorHint.
  ///
  /// In ru, this message translates to:
  /// **'Цвет букв'**
  String get pFontColorHint;

  /// No description provided for @colorWhite.
  ///
  /// In ru, this message translates to:
  /// **'белый'**
  String get colorWhite;

  /// No description provided for @colorBlack.
  ///
  /// In ru, this message translates to:
  /// **'чёрный'**
  String get colorBlack;

  /// No description provided for @colorYellow.
  ///
  /// In ru, this message translates to:
  /// **'жёлтый'**
  String get colorYellow;

  /// No description provided for @colorRed.
  ///
  /// In ru, this message translates to:
  /// **'красный'**
  String get colorRed;

  /// No description provided for @colorBlue.
  ///
  /// In ru, this message translates to:
  /// **'голубой'**
  String get colorBlue;

  /// No description provided for @pTextBox.
  ///
  /// In ru, this message translates to:
  /// **'Подложка'**
  String get pTextBox;

  /// No description provided for @pTextBoxHint.
  ///
  /// In ru, this message translates to:
  /// **'Полупрозрачный прямоугольник под текстом; без неё — обводка'**
  String get pTextBoxHint;

  /// No description provided for @pFontFile.
  ///
  /// In ru, this message translates to:
  /// **'Шрифт'**
  String get pFontFile;

  /// No description provided for @pFontFileHint.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию — системный шрифт без засечек'**
  String get pFontFileHint;

  /// No description provided for @pTimecode.
  ///
  /// In ru, this message translates to:
  /// **'Таймкод'**
  String get pTimecode;

  /// No description provided for @pTimecodeHint.
  ///
  /// In ru, this message translates to:
  /// **'Время от начала видео на каждом кадре'**
  String get pTimecodeHint;

  /// No description provided for @pTimecodePosition.
  ///
  /// In ru, this message translates to:
  /// **'Положение таймкода'**
  String get pTimecodePosition;

  /// No description provided for @groupWhen.
  ///
  /// In ru, this message translates to:
  /// **'Отступ и время показа'**
  String get groupWhen;

  /// No description provided for @pMargin.
  ///
  /// In ru, this message translates to:
  /// **'Отступ от края'**
  String get pMargin;

  /// No description provided for @pMarginHint.
  ///
  /// In ru, this message translates to:
  /// **'Относительно высоты видео'**
  String get pMarginHint;

  /// No description provided for @pShowFrom.
  ///
  /// In ru, this message translates to:
  /// **'Показывать с'**
  String get pShowFrom;

  /// No description provided for @pShowFromHint.
  ///
  /// In ru, this message translates to:
  /// **'Пусто — с начала'**
  String get pShowFromHint;

  /// No description provided for @pShowTo.
  ///
  /// In ru, this message translates to:
  /// **'Показывать до'**
  String get pShowTo;

  /// No description provided for @pShowToHint.
  ///
  /// In ru, this message translates to:
  /// **'Пусто — до конца'**
  String get pShowToHint;

  /// No description provided for @overlayEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Выберите картинку, введите текст или включите таймкод'**
  String get overlayEmpty;

  /// No description provided for @cornerTopLeft.
  ///
  /// In ru, this message translates to:
  /// **'слева вверху'**
  String get cornerTopLeft;

  /// No description provided for @cornerTop.
  ///
  /// In ru, this message translates to:
  /// **'вверху по центру'**
  String get cornerTop;

  /// No description provided for @cornerTopRight.
  ///
  /// In ru, this message translates to:
  /// **'справа вверху'**
  String get cornerTopRight;

  /// No description provided for @cornerLeft.
  ///
  /// In ru, this message translates to:
  /// **'слева по центру'**
  String get cornerLeft;

  /// No description provided for @cornerCenter.
  ///
  /// In ru, this message translates to:
  /// **'в центре'**
  String get cornerCenter;

  /// No description provided for @cornerRight.
  ///
  /// In ru, this message translates to:
  /// **'справа по центру'**
  String get cornerRight;

  /// No description provided for @cornerBottomLeft.
  ///
  /// In ru, this message translates to:
  /// **'слева внизу'**
  String get cornerBottomLeft;

  /// No description provided for @cornerBottom.
  ///
  /// In ru, this message translates to:
  /// **'внизу по центру'**
  String get cornerBottom;

  /// No description provided for @cornerBottomRight.
  ///
  /// In ru, this message translates to:
  /// **'справа внизу'**
  String get cornerBottomRight;

  /// No description provided for @groupBlur.
  ///
  /// In ru, this message translates to:
  /// **'Скрытие'**
  String get groupBlur;

  /// No description provided for @pBlurMode.
  ///
  /// In ru, this message translates to:
  /// **'Способ'**
  String get pBlurMode;

  /// No description provided for @blurModeBlur.
  ///
  /// In ru, this message translates to:
  /// **'Размыть'**
  String get blurModeBlur;

  /// No description provided for @blurModePixel.
  ///
  /// In ru, this message translates to:
  /// **'Пиксели'**
  String get blurModePixel;

  /// No description provided for @blurModeDelogo.
  ///
  /// In ru, this message translates to:
  /// **'Убрать логотип'**
  String get blurModeDelogo;

  /// No description provided for @blurModeBox.
  ///
  /// In ru, this message translates to:
  /// **'Закрасить'**
  String get blurModeBox;

  /// No description provided for @blurModeBlurHint.
  ///
  /// In ru, this message translates to:
  /// **'Лица, номера машин, экраны'**
  String get blurModeBlurHint;

  /// No description provided for @blurModePixelHint.
  ///
  /// In ru, this message translates to:
  /// **'Крупные квадраты, как в новостях'**
  String get blurModePixelHint;

  /// No description provided for @blurModeDelogoHint.
  ///
  /// In ru, this message translates to:
  /// **'Заполняет область по соседним пикселям — для небольших логотипов на однородном фоне'**
  String get blurModeDelogoHint;

  /// No description provided for @blurModeBoxHint.
  ///
  /// In ru, this message translates to:
  /// **'Чёрный прямоугольник'**
  String get blurModeBoxHint;

  /// No description provided for @pStrength.
  ///
  /// In ru, this message translates to:
  /// **'Сила'**
  String get pStrength;

  /// No description provided for @pBlurStrengthHint.
  ///
  /// In ru, this message translates to:
  /// **'Насколько сильно скрывать'**
  String get pBlurStrengthHint;

  /// No description provided for @pBlurWhole.
  ///
  /// In ru, this message translates to:
  /// **'Весь кадр'**
  String get pBlurWhole;

  /// No description provided for @pBlurWholeHint.
  ///
  /// In ru, this message translates to:
  /// **'Размыть всё изображение целиком'**
  String get pBlurWholeHint;

  /// No description provided for @pEditRegions.
  ///
  /// In ru, this message translates to:
  /// **'Рисовать области'**
  String get pEditRegions;

  /// No description provided for @pEditRegionsHint.
  ///
  /// In ru, this message translates to:
  /// **'Выключите, чтобы посмотреть результат в предпросмотре'**
  String get pEditRegionsHint;

  /// No description provided for @groupRegions.
  ///
  /// In ru, this message translates to:
  /// **'Области'**
  String get groupRegions;

  /// No description provided for @regionTimeHint.
  ///
  /// In ru, this message translates to:
  /// **'Для каждой области можно задать время: пусто — всё видео'**
  String get regionTimeHint;

  /// No description provided for @blurNoRegions.
  ///
  /// In ru, this message translates to:
  /// **'Нарисуйте на кадре хотя бы одну область'**
  String get blurNoRegions;

  /// No description provided for @groupLayout.
  ///
  /// In ru, this message translates to:
  /// **'Расположение'**
  String get groupLayout;

  /// No description provided for @pLayout.
  ///
  /// In ru, this message translates to:
  /// **'Как разместить'**
  String get pLayout;

  /// No description provided for @pLayoutHint.
  ///
  /// In ru, this message translates to:
  /// **'Высота или ширина подгоняется под первое видео'**
  String get pLayoutHint;

  /// No description provided for @layoutSide.
  ///
  /// In ru, this message translates to:
  /// **'Рядом'**
  String get layoutSide;

  /// No description provided for @layoutTop.
  ///
  /// In ru, this message translates to:
  /// **'Друг над другом'**
  String get layoutTop;

  /// No description provided for @layoutGrid.
  ///
  /// In ru, this message translates to:
  /// **'Сетка 2×2'**
  String get layoutGrid;

  /// No description provided for @layoutPip.
  ///
  /// In ru, this message translates to:
  /// **'Картинка в картинке'**
  String get layoutPip;

  /// No description provided for @pPipPositionHint.
  ///
  /// In ru, this message translates to:
  /// **'Где будет маленькое окно'**
  String get pPipPositionHint;

  /// No description provided for @pPipSize.
  ///
  /// In ru, this message translates to:
  /// **'Размер окна'**
  String get pPipSize;

  /// No description provided for @pPipSizeHint.
  ///
  /// In ru, this message translates to:
  /// **'Относительно ширины основного видео'**
  String get pPipSizeHint;

  /// No description provided for @pStackAudio.
  ///
  /// In ru, this message translates to:
  /// **'Звук'**
  String get pStackAudio;

  /// No description provided for @pStackAudioHint.
  ///
  /// In ru, this message translates to:
  /// **'Чей звук будет в результате'**
  String get pStackAudioHint;

  /// No description provided for @stackAudioFirst.
  ///
  /// In ru, this message translates to:
  /// **'Первого видео'**
  String get stackAudioFirst;

  /// No description provided for @stackAudioMix.
  ///
  /// In ru, this message translates to:
  /// **'Смешать все'**
  String get stackAudioMix;

  /// No description provided for @stackAudioNone.
  ///
  /// In ru, this message translates to:
  /// **'Без звука'**
  String get stackAudioNone;

  /// No description provided for @shortestOnHint.
  ///
  /// In ru, this message translates to:
  /// **'Результат длится, пока идут все видео'**
  String get shortestOnHint;

  /// No description provided for @shortestOffHint.
  ///
  /// In ru, this message translates to:
  /// **'До конца самого длинного; закончившиеся застывают на последнем кадре'**
  String get shortestOffHint;

  /// No description provided for @groupLoop.
  ///
  /// In ru, this message translates to:
  /// **'Повтор'**
  String get groupLoop;

  /// No description provided for @pLoopMode.
  ///
  /// In ru, this message translates to:
  /// **'Режим'**
  String get pLoopMode;

  /// No description provided for @loopRepeat.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get loopRepeat;

  /// No description provided for @loopBoomerang.
  ///
  /// In ru, this message translates to:
  /// **'Бумеранг'**
  String get loopBoomerang;

  /// No description provided for @loopRepeatHint.
  ///
  /// In ru, this message translates to:
  /// **'Видео проигрывается несколько раз подряд'**
  String get loopRepeatHint;

  /// No description provided for @loopBoomerangHint.
  ///
  /// In ru, this message translates to:
  /// **'Вперёд, затем назад — бесшовная петля'**
  String get loopBoomerangHint;

  /// No description provided for @pLoopTimes.
  ///
  /// In ru, this message translates to:
  /// **'Сколько раз'**
  String get pLoopTimes;

  /// No description provided for @pLoopTimesHint.
  ///
  /// In ru, this message translates to:
  /// **'Общее число проигрываний'**
  String get pLoopTimesHint;

  /// No description provided for @pBoomerangAudio.
  ///
  /// In ru, this message translates to:
  /// **'Со звуком'**
  String get pBoomerangAudio;

  /// No description provided for @pBoomerangAudioHint.
  ///
  /// In ru, this message translates to:
  /// **'Звук тоже проиграется задом наперёд'**
  String get pBoomerangAudioHint;

  /// No description provided for @groupToneMap.
  ///
  /// In ru, this message translates to:
  /// **'Тональная компрессия'**
  String get groupToneMap;

  /// No description provided for @hdrSourceInfo.
  ///
  /// In ru, this message translates to:
  /// **'Исходник: передаточная функция {trc}, цвета {prim}, {bits} бит'**
  String hdrSourceInfo(String trc, String prim, String bits);

  /// No description provided for @notHdrWarning.
  ///
  /// In ru, this message translates to:
  /// **'Файл не похож на HDR (передаточная функция: {trc}) — результат может выглядеть неверно'**
  String notHdrWarning(String trc);

  /// No description provided for @pToneCurve.
  ///
  /// In ru, this message translates to:
  /// **'Кривая'**
  String get pToneCurve;

  /// No description provided for @pToneCurveHelp.
  ///
  /// In ru, this message translates to:
  /// **'HDR-видео содержит яркость, которую обычный экран показать не может. Кривая решает, как «сжать» её в обычный диапазон. Hable сохраняет детали в светах и тенях (хороший выбор по умолчанию), Möbius — точнее цвета в средних тонах, Reinhard — мягкий и светлый результат.'**
  String get pToneCurveHelp;

  /// No description provided for @toneHableHint.
  ///
  /// In ru, this message translates to:
  /// **'Сохраняет детали в светах — хороший выбор по умолчанию'**
  String get toneHableHint;

  /// No description provided for @toneMobiusHint.
  ///
  /// In ru, this message translates to:
  /// **'Точнее цвета в средних тонах'**
  String get toneMobiusHint;

  /// No description provided for @toneReinhardHint.
  ///
  /// In ru, this message translates to:
  /// **'Мягкий, светлый результат'**
  String get toneReinhardHint;

  /// No description provided for @toneBt2390Hint.
  ///
  /// In ru, this message translates to:
  /// **'Стандарт ITU для вещания'**
  String get toneBt2390Hint;

  /// No description provided for @pDesat.
  ///
  /// In ru, this message translates to:
  /// **'Обесцвечивание светов'**
  String get pDesat;

  /// No description provided for @pDesatHint.
  ///
  /// In ru, this message translates to:
  /// **'Убирает неестественно яркие цвета в светлых местах'**
  String get pDesatHint;

  /// No description provided for @pPlacebo.
  ///
  /// In ru, this message translates to:
  /// **'Через видеокарту (libplacebo)'**
  String get pPlacebo;

  /// No description provided for @pPlaceboHint.
  ///
  /// In ru, this message translates to:
  /// **'Быстрее и качественнее; нужна видеокарта с Vulkan'**
  String get pPlaceboHint;

  /// No description provided for @groupResults.
  ///
  /// In ru, this message translates to:
  /// **'Результаты'**
  String get groupResults;

  /// No description provided for @groupMeasure.
  ///
  /// In ru, this message translates to:
  /// **'Замер'**
  String get groupMeasure;

  /// No description provided for @measure.
  ///
  /// In ru, this message translates to:
  /// **'Измерить'**
  String get measure;

  /// No description provided for @pAudioTrack.
  ///
  /// In ru, this message translates to:
  /// **'Звуковая дорожка'**
  String get pAudioTrack;

  /// No description provided for @pAudioTrackHint.
  ///
  /// In ru, this message translates to:
  /// **'Какую дорожку измерять'**
  String get pAudioTrackHint;

  /// No description provided for @pLoudnessTarget.
  ///
  /// In ru, this message translates to:
  /// **'Сравнить с'**
  String get pLoudnessTarget;

  /// No description provided for @pLoudnessTargetHint.
  ///
  /// In ru, this message translates to:
  /// **'Норма громкости площадки'**
  String get pLoudnessTargetHint;

  /// No description provided for @groupWhatIsLufs.
  ///
  /// In ru, this message translates to:
  /// **'Что означают цифры'**
  String get groupWhatIsLufs;

  /// No description provided for @lufsExplained.
  ///
  /// In ru, this message translates to:
  /// **'Интегральная громкость (LUFS) — средняя громкость всего файла так, как её слышит человек. Площадки выравнивают громкость: YouTube и Spotify приводят всё к −14 LUFS, поэтому слишком громкий трек просто сделают тише, а тихий прозвучит слабее остальных.\n\nTrue Peak — настоящий пик сигнала с учётом пересчёта в аналог; выше −1 dBTP возможны искажения после сжатия в MP3/AAC.\n\nДиапазон (LRA) — насколько различаются тихие и громкие места: 5–10 LU для музыки, больше 15 — кино с тихими диалогами и взрывами.'**
  String get lufsExplained;

  /// No description provided for @statIntegratedNote.
  ///
  /// In ru, this message translates to:
  /// **'средняя за весь файл'**
  String get statIntegratedNote;

  /// No description provided for @statTruePeakNote.
  ///
  /// In ru, this message translates to:
  /// **'максимальный пик'**
  String get statTruePeakNote;

  /// No description provided for @statLraNote.
  ///
  /// In ru, this message translates to:
  /// **'разброс громкости'**
  String get statLraNote;

  /// No description provided for @statMaxMomentary.
  ///
  /// In ru, this message translates to:
  /// **'Макс. мгновенная'**
  String get statMaxMomentary;

  /// No description provided for @statMaxShort.
  ///
  /// In ru, this message translates to:
  /// **'Макс. кратковременная'**
  String get statMaxShort;

  /// No description provided for @loudnessLegend.
  ///
  /// In ru, this message translates to:
  /// **'Тонкая линия — мгновенная громкость (0,4 с), толстая — кратковременная (3 с), пунктир — норма площадки.'**
  String get loudnessLegend;

  /// No description provided for @loudnessOnTarget.
  ///
  /// In ru, this message translates to:
  /// **'Громкость соответствует норме {name}.'**
  String loudnessOnTarget(String name);

  /// No description provided for @loudnessTooLoud.
  ///
  /// In ru, this message translates to:
  /// **'Громче нормы {name} на {db} дБ — площадка сделает тише.'**
  String loudnessTooLoud(String name, String db);

  /// No description provided for @loudnessTooQuiet.
  ///
  /// In ru, this message translates to:
  /// **'Тише нормы {name} на {db} дБ — будет звучать слабее других.'**
  String loudnessTooQuiet(String name, String db);

  /// No description provided for @truePeakOver.
  ///
  /// In ru, this message translates to:
  /// **'Пик {tp} dBTP выше допустимых {limit} dBTP — возможны искажения.'**
  String truePeakOver(String tp, String limit);

  /// No description provided for @openNormalize.
  ///
  /// In ru, this message translates to:
  /// **'Нормализовать громкость'**
  String get openNormalize;

  /// No description provided for @groupPicture.
  ///
  /// In ru, this message translates to:
  /// **'Картинка'**
  String get groupPicture;

  /// No description provided for @pPicKind.
  ///
  /// In ru, this message translates to:
  /// **'Что рисовать'**
  String get pPicKind;

  /// No description provided for @picWave.
  ///
  /// In ru, this message translates to:
  /// **'Осциллограмма'**
  String get picWave;

  /// No description provided for @picSpectrum.
  ///
  /// In ru, this message translates to:
  /// **'Спектрограмма'**
  String get picSpectrum;

  /// No description provided for @picWaveHint.
  ///
  /// In ru, this message translates to:
  /// **'Форма волны: громкость во времени'**
  String get picWaveHint;

  /// No description provided for @picSpectrumHint.
  ///
  /// In ru, this message translates to:
  /// **'Частоты во времени: видно шум, гул, срезы'**
  String get picSpectrumHint;

  /// No description provided for @pPicSize.
  ///
  /// In ru, this message translates to:
  /// **'Размер'**
  String get pPicSize;

  /// No description provided for @pPicSizeHint.
  ///
  /// In ru, this message translates to:
  /// **'В пикселях'**
  String get pPicSizeHint;

  /// No description provided for @pSplitChannels.
  ///
  /// In ru, this message translates to:
  /// **'Каналы отдельно'**
  String get pSplitChannels;

  /// No description provided for @pSplitChannelsHint.
  ///
  /// In ru, this message translates to:
  /// **'Левый и правый — друг под другом'**
  String get pSplitChannelsHint;

  /// No description provided for @pWaveColorHint.
  ///
  /// In ru, this message translates to:
  /// **'Цвет волны'**
  String get pWaveColorHint;

  /// No description provided for @pWaveScale.
  ///
  /// In ru, this message translates to:
  /// **'Шкала'**
  String get pWaveScale;

  /// No description provided for @pWaveScaleHint.
  ///
  /// In ru, this message translates to:
  /// **'Логарифмическая лучше показывает тихие места'**
  String get pWaveScaleHint;

  /// No description provided for @scaleLinear.
  ///
  /// In ru, this message translates to:
  /// **'линейная'**
  String get scaleLinear;

  /// No description provided for @scaleLog.
  ///
  /// In ru, this message translates to:
  /// **'логарифмическая'**
  String get scaleLog;

  /// No description provided for @scaleSqrt.
  ///
  /// In ru, this message translates to:
  /// **'квадратный корень'**
  String get scaleSqrt;

  /// No description provided for @scaleCbrt.
  ///
  /// In ru, this message translates to:
  /// **'кубический корень'**
  String get scaleCbrt;

  /// No description provided for @pSpectrumColors.
  ///
  /// In ru, this message translates to:
  /// **'Палитра'**
  String get pSpectrumColors;

  /// No description provided for @pSpectrumColorsHint.
  ///
  /// In ru, this message translates to:
  /// **'Цвета для уровней'**
  String get pSpectrumColorsHint;

  /// No description provided for @pLogFrequency.
  ///
  /// In ru, this message translates to:
  /// **'Логарифмическая шкала частот'**
  String get pLogFrequency;

  /// No description provided for @pLogFrequencyHint.
  ///
  /// In ru, this message translates to:
  /// **'Больше места низким частотам, как слышит ухо'**
  String get pLogFrequencyHint;

  /// No description provided for @pLegend.
  ///
  /// In ru, this message translates to:
  /// **'Подписи'**
  String get pLegend;

  /// No description provided for @pLegendHint.
  ///
  /// In ru, this message translates to:
  /// **'Оси времени и частот'**
  String get pLegendHint;

  /// No description provided for @savePng.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить PNG'**
  String get savePng;

  /// No description provided for @savedTo.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено: {path}'**
  String savedTo(String path);

  /// No description provided for @groupDetect.
  ///
  /// In ru, this message translates to:
  /// **'Детектор'**
  String get groupDetect;

  /// No description provided for @pDetectKind.
  ///
  /// In ru, this message translates to:
  /// **'Что искать'**
  String get pDetectKind;

  /// No description provided for @detectSilence.
  ///
  /// In ru, this message translates to:
  /// **'Тишина'**
  String get detectSilence;

  /// No description provided for @detectBlack.
  ///
  /// In ru, this message translates to:
  /// **'Чёрные кадры'**
  String get detectBlack;

  /// No description provided for @detectFreeze.
  ///
  /// In ru, this message translates to:
  /// **'Застывшие кадры'**
  String get detectFreeze;

  /// No description provided for @detectScenes.
  ///
  /// In ru, this message translates to:
  /// **'Смена сцен'**
  String get detectScenes;

  /// No description provided for @detectCrop.
  ///
  /// In ru, this message translates to:
  /// **'Чёрные поля'**
  String get detectCrop;

  /// No description provided for @detectSilenceHint.
  ///
  /// In ru, this message translates to:
  /// **'Паузы в звуке — например, чтобы вырезать их'**
  String get detectSilenceHint;

  /// No description provided for @detectBlackHint.
  ///
  /// In ru, this message translates to:
  /// **'Затемнения, рекламные паузы, пустое начало'**
  String get detectBlackHint;

  /// No description provided for @detectFreezeHint.
  ///
  /// In ru, this message translates to:
  /// **'Зависшее изображение, пропавший сигнал'**
  String get detectFreezeHint;

  /// No description provided for @detectScenesHint.
  ///
  /// In ru, this message translates to:
  /// **'Моменты монтажных склеек'**
  String get detectScenesHint;

  /// No description provided for @detectCropHint.
  ///
  /// In ru, this message translates to:
  /// **'Полосы по краям кадра, которые можно обрезать'**
  String get detectCropHint;

  /// No description provided for @pSilenceLevel.
  ///
  /// In ru, this message translates to:
  /// **'Порог тишины'**
  String get pSilenceLevel;

  /// No description provided for @pSilenceLevelHint.
  ///
  /// In ru, this message translates to:
  /// **'Всё тише этого уровня считается тишиной'**
  String get pSilenceLevelHint;

  /// No description provided for @pBlackLevel.
  ///
  /// In ru, this message translates to:
  /// **'Порог чёрного'**
  String get pBlackLevel;

  /// No description provided for @pBlackLevelHint.
  ///
  /// In ru, this message translates to:
  /// **'Насколько тёмный пиксель считается чёрным'**
  String get pBlackLevelHint;

  /// No description provided for @pFreezeNoise.
  ///
  /// In ru, this message translates to:
  /// **'Допустимый шум'**
  String get pFreezeNoise;

  /// No description provided for @pFreezeNoiseHint.
  ///
  /// In ru, this message translates to:
  /// **'Больше — застывшими считаются и слегка шумящие кадры'**
  String get pFreezeNoiseHint;

  /// No description provided for @pSceneThreshold.
  ///
  /// In ru, this message translates to:
  /// **'Чувствительность'**
  String get pSceneThreshold;

  /// No description provided for @pSceneThresholdHint.
  ///
  /// In ru, this message translates to:
  /// **'Меньше — находит больше склеек, в том числе ложные'**
  String get pSceneThresholdHint;

  /// No description provided for @pMinDuration.
  ///
  /// In ru, this message translates to:
  /// **'Минимальная длина'**
  String get pMinDuration;

  /// No description provided for @pMinDurationHint.
  ///
  /// In ru, this message translates to:
  /// **'Более короткие участки не считаются'**
  String get pMinDurationHint;

  /// No description provided for @detectRun.
  ///
  /// In ru, this message translates to:
  /// **'Найти'**
  String get detectRun;

  /// No description provided for @foundCount.
  ///
  /// In ru, this message translates to:
  /// **'Найдено: {n}'**
  String foundCount(int n);

  /// No description provided for @moreFound.
  ///
  /// In ru, this message translates to:
  /// **'…и ещё {n}'**
  String moreFound(int n);

  /// No description provided for @sceneScore.
  ///
  /// In ru, this message translates to:
  /// **'сила {v}'**
  String sceneScore(String v);

  /// No description provided for @saveCsv.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить CSV'**
  String get saveCsv;

  /// No description provided for @cutFound.
  ///
  /// In ru, this message translates to:
  /// **'Вырезать найденное'**
  String get cutFound;

  /// No description provided for @splitAtFound.
  ///
  /// In ru, this message translates to:
  /// **'Разделить в этих местах'**
  String get splitAtFound;

  /// No description provided for @cropFound.
  ///
  /// In ru, this message translates to:
  /// **'Можно обрезать до {size} от точки {x}, {y}'**
  String cropFound(String size, String x, String y);

  /// No description provided for @openCropTool.
  ///
  /// In ru, this message translates to:
  /// **'Открыть в «Кадр и размер»'**
  String get openCropTool;

  /// No description provided for @groupCompare.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение'**
  String get groupCompare;

  /// No description provided for @referenceFile.
  ///
  /// In ru, this message translates to:
  /// **'Оригинал'**
  String get referenceFile;

  /// No description provided for @distortedFile.
  ///
  /// In ru, this message translates to:
  /// **'Сжатая версия'**
  String get distortedFile;

  /// No description provided for @distortedFileHint.
  ///
  /// In ru, this message translates to:
  /// **'Выберите файл, качество которого нужно оценить'**
  String get distortedFileHint;

  /// No description provided for @qualityScaledNote.
  ///
  /// In ru, this message translates to:
  /// **'Размеры кадра разные — сжатая версия будет приведена к размеру оригинала.'**
  String get qualityScaledNote;

  /// No description provided for @vmafMissing.
  ///
  /// In ru, this message translates to:
  /// **'В этой сборке нет VMAF — будут посчитаны только PSNR и SSIM. VMAF есть в полной сборке ffmpeg (раздел «Компоненты»).'**
  String get vmafMissing;

  /// No description provided for @compareRun.
  ///
  /// In ru, this message translates to:
  /// **'Сравнить'**
  String get compareRun;

  /// No description provided for @groupWhatMetrics.
  ///
  /// In ru, this message translates to:
  /// **'Что означают метрики'**
  String get groupWhatMetrics;

  /// No description provided for @metricsExplained.
  ///
  /// In ru, this message translates to:
  /// **'VMAF (0–100) — оценка Netflix, лучше всего совпадает с тем, как качество видит человек: выше 93 — отличий не видно, 80–93 — хорошо, ниже 60 — заметные дефекты.\n\nPSNR (дБ) — математическая разница пикселей: выше 40 — отлично, 30–35 — заметные потери.\n\nSSIM (0–1) — похожесть структуры изображения: 0,98 и выше — почти неотличимо.\n\nФайлы сравниваются кадр за кадром с начала, поэтому они должны начинаться с одного и того же кадра.'**
  String get metricsExplained;

  /// No description provided for @psnrMin.
  ///
  /// In ru, this message translates to:
  /// **'худший кадр {v} dB'**
  String psnrMin(String v);

  /// No description provided for @qualityExcellent.
  ///
  /// In ru, this message translates to:
  /// **'отлично'**
  String get qualityExcellent;

  /// No description provided for @qualityGood.
  ///
  /// In ru, this message translates to:
  /// **'хорошо'**
  String get qualityGood;

  /// No description provided for @qualityFair.
  ///
  /// In ru, this message translates to:
  /// **'заметные потери'**
  String get qualityFair;

  /// No description provided for @qualityPoor.
  ///
  /// In ru, this message translates to:
  /// **'плохо'**
  String get qualityPoor;

  /// No description provided for @vmafVerdictExcellent.
  ///
  /// In ru, this message translates to:
  /// **'Сжатая версия на глаз неотличима от оригинала.'**
  String get vmafVerdictExcellent;

  /// No description provided for @vmafVerdictGood.
  ///
  /// In ru, this message translates to:
  /// **'Хорошее качество: отличия видны только при внимательном сравнении.'**
  String get vmafVerdictGood;

  /// No description provided for @vmafVerdictFair.
  ///
  /// In ru, this message translates to:
  /// **'Потери заметны — попробуйте качество повыше.'**
  String get vmafVerdictFair;

  /// No description provided for @vmafVerdictPoor.
  ///
  /// In ru, this message translates to:
  /// **'Сильные потери качества.'**
  String get vmafVerdictPoor;

  /// No description provided for @groupChain.
  ///
  /// In ru, this message translates to:
  /// **'Цепочка обработки'**
  String get groupChain;

  /// No description provided for @addEffect.
  ///
  /// In ru, this message translates to:
  /// **'Добавить эффект'**
  String get addEffect;

  /// No description provided for @chainHowTo.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте эффекты — они применяются сверху вниз ко всему звуку файла. Видео копируется без изменений.'**
  String get chainHowTo;

  /// No description provided for @chainEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте хотя бы один эффект'**
  String get chainEmpty;

  /// No description provided for @fxRnnoise.
  ///
  /// In ru, this message translates to:
  /// **'Подавление шума нейросетью (RNNoise)'**
  String get fxRnnoise;

  /// No description provided for @fxRnnoiseDesc.
  ///
  /// In ru, this message translates to:
  /// **'Лучше всего для речи: убирает шум улицы, вентиляторов, клавиатуры'**
  String get fxRnnoiseDesc;

  /// No description provided for @rnnoiseNeedsModel.
  ///
  /// In ru, this message translates to:
  /// **'Нужна модель — установите её ниже, в разделе «Модели RNNoise»'**
  String get rnnoiseNeedsModel;

  /// No description provided for @rnnoiseSuggest.
  ///
  /// In ru, this message translates to:
  /// **'Для речи лучше всего работает нейросетевое подавление (RNNoise) — установите модель ниже (около 300 КБ).'**
  String get rnnoiseSuggest;

  /// No description provided for @pRnnoiseModel.
  ///
  /// In ru, this message translates to:
  /// **'Модель'**
  String get pRnnoiseModel;

  /// No description provided for @pRnnoiseModelHint.
  ///
  /// In ru, this message translates to:
  /// **'Разные модели обучены на разных шумах'**
  String get pRnnoiseModelHint;

  /// No description provided for @pRnnoiseMixHint.
  ///
  /// In ru, this message translates to:
  /// **'Меньше — сохраняется часть исходного звука, естественнее'**
  String get pRnnoiseMixHint;

  /// No description provided for @groupListen.
  ///
  /// In ru, this message translates to:
  /// **'Прослушать до и после'**
  String get groupListen;

  /// No description provided for @pListenFrom.
  ///
  /// In ru, this message translates to:
  /// **'С какого места'**
  String get pListenFrom;

  /// No description provided for @pListenFromHint.
  ///
  /// In ru, this message translates to:
  /// **'Начало фрагмента для прослушивания'**
  String get pListenFromHint;

  /// No description provided for @pListenLength.
  ///
  /// In ru, this message translates to:
  /// **'Длина фрагмента'**
  String get pListenLength;

  /// No description provided for @pListenLengthHint.
  ///
  /// In ru, this message translates to:
  /// **'Сколько секунд обработать для пробы'**
  String get pListenLengthHint;

  /// No description provided for @listen.
  ///
  /// In ru, this message translates to:
  /// **'Слушать'**
  String get listen;

  /// No description provided for @abListenHint.
  ///
  /// In ru, this message translates to:
  /// **'Оба варианта играют одновременно — переключайте «До» и «После», чтобы сравнить без пауз.'**
  String get abListenHint;

  /// No description provided for @modelsRnnoise.
  ///
  /// In ru, this message translates to:
  /// **'Модели RNNoise'**
  String get modelsRnnoise;

  /// No description provided for @modelsWhisper.
  ///
  /// In ru, this message translates to:
  /// **'Модели Whisper'**
  String get modelsWhisper;

  /// No description provided for @modelsRnnoiseHint.
  ///
  /// In ru, this message translates to:
  /// **'Нейросети для подавления шума в речи. Скачиваются с GitHub (GregorR/rnnoise-models), проверяются по SHA-256.'**
  String get modelsRnnoiseHint;

  /// No description provided for @modelsWhisperHint.
  ///
  /// In ru, this message translates to:
  /// **'Модели распознавания речи whisper.cpp. Скачиваются с Hugging Face, проверяются по SHA-256. Чем больше модель, тем точнее и медленнее.'**
  String get modelsWhisperHint;

  /// No description provided for @modelRnnSh.
  ///
  /// In ru, this message translates to:
  /// **'Универсальная (sh)'**
  String get modelRnnSh;

  /// No description provided for @modelRnnShNote.
  ///
  /// In ru, this message translates to:
  /// **'речь и шум — хороший выбор по умолчанию'**
  String get modelRnnShNote;

  /// No description provided for @modelRnnBd.
  ///
  /// In ru, this message translates to:
  /// **'Голос + шум (bd)'**
  String get modelRnnBd;

  /// No description provided for @modelRnnBdNote.
  ///
  /// In ru, this message translates to:
  /// **'обучена на голосе с фоновым шумом'**
  String get modelRnnBdNote;

  /// No description provided for @modelRnnCb.
  ///
  /// In ru, this message translates to:
  /// **'Записанный шум (cb)'**
  String get modelRnnCb;

  /// No description provided for @modelRnnCbNote.
  ///
  /// In ru, this message translates to:
  /// **'для типичных шумов записи'**
  String get modelRnnCbNote;

  /// No description provided for @modelRnnLq.
  ///
  /// In ru, this message translates to:
  /// **'Мягкая (lq)'**
  String get modelRnnLq;

  /// No description provided for @modelRnnLqNote.
  ///
  /// In ru, this message translates to:
  /// **'общая, бережнее к голосу'**
  String get modelRnnLqNote;

  /// No description provided for @modelRnnMp.
  ///
  /// In ru, this message translates to:
  /// **'Только голос (mp)'**
  String get modelRnnMp;

  /// No description provided for @modelRnnMpNote.
  ///
  /// In ru, this message translates to:
  /// **'убирает всё, кроме голоса'**
  String get modelRnnMpNote;

  /// No description provided for @modelWhisperTinyNote.
  ///
  /// In ru, this message translates to:
  /// **'самая быстрая, для черновиков'**
  String get modelWhisperTinyNote;

  /// No description provided for @modelWhisperBaseNote.
  ///
  /// In ru, this message translates to:
  /// **'быстрая, приемлемая точность'**
  String get modelWhisperBaseNote;

  /// No description provided for @modelWhisperSmallNote.
  ///
  /// In ru, this message translates to:
  /// **'хороший баланс для русского'**
  String get modelWhisperSmallNote;

  /// No description provided for @modelWhisperMediumNote.
  ///
  /// In ru, this message translates to:
  /// **'точная, медленнее'**
  String get modelWhisperMediumNote;

  /// No description provided for @modelWhisperTurboNote.
  ///
  /// In ru, this message translates to:
  /// **'самая точная; лучше с видеокартой'**
  String get modelWhisperTurboNote;

  /// No description provided for @groupMusic.
  ///
  /// In ru, this message translates to:
  /// **'Музыка'**
  String get groupMusic;

  /// No description provided for @musicFile.
  ///
  /// In ru, this message translates to:
  /// **'Файл музыки'**
  String get musicFile;

  /// No description provided for @musicFileHint.
  ///
  /// In ru, this message translates to:
  /// **'MP3, FLAC, WAV — любой звук'**
  String get musicFileHint;

  /// No description provided for @musicChoose.
  ///
  /// In ru, this message translates to:
  /// **'Выберите файл музыки'**
  String get musicChoose;

  /// No description provided for @pMusicVolume.
  ///
  /// In ru, this message translates to:
  /// **'Громкость музыки'**
  String get pMusicVolume;

  /// No description provided for @pMusicVolumeHint.
  ///
  /// In ru, this message translates to:
  /// **'Относительно исходной громкости музыки'**
  String get pMusicVolumeHint;

  /// No description provided for @pMusicLoop.
  ///
  /// In ru, this message translates to:
  /// **'Повторять'**
  String get pMusicLoop;

  /// No description provided for @pMusicLoopHint.
  ///
  /// In ru, this message translates to:
  /// **'Если музыка короче видео, она начнётся заново'**
  String get pMusicLoopHint;

  /// No description provided for @pMusicOffset.
  ///
  /// In ru, this message translates to:
  /// **'Начать с'**
  String get pMusicOffset;

  /// No description provided for @pMusicOffsetHint.
  ///
  /// In ru, this message translates to:
  /// **'Музыка вступает с этого момента видео'**
  String get pMusicOffsetHint;

  /// No description provided for @pMusicFadeOut.
  ///
  /// In ru, this message translates to:
  /// **'Затухание в конце'**
  String get pMusicFadeOut;

  /// No description provided for @pMusicFadeOutHint.
  ///
  /// In ru, this message translates to:
  /// **'Музыка плавно стихает к концу видео'**
  String get pMusicFadeOutHint;

  /// No description provided for @groupOriginalAudio.
  ///
  /// In ru, this message translates to:
  /// **'Звук файла'**
  String get groupOriginalAudio;

  /// No description provided for @pKeepOriginalAudio.
  ///
  /// In ru, this message translates to:
  /// **'Оставить исходный звук'**
  String get pKeepOriginalAudio;

  /// No description provided for @pKeepOriginalAudioHint.
  ///
  /// In ru, this message translates to:
  /// **'Иначе музыка заменит звук полностью'**
  String get pKeepOriginalAudioHint;

  /// No description provided for @pDuck.
  ///
  /// In ru, this message translates to:
  /// **'Приглушать музыку под голос'**
  String get pDuck;

  /// No description provided for @pDuckHint.
  ///
  /// In ru, this message translates to:
  /// **'Музыка становится тише, когда в исходном звуке говорят'**
  String get pDuckHint;

  /// No description provided for @pDuckHelp.
  ///
  /// In ru, this message translates to:
  /// **'Компрессор с боковой цепью (sidechaincompress) следит за громкостью исходного звука и, когда он звучит, опускает уровень музыки. В паузах музыка возвращается. Так делают в подкастах, влогах и рекламе.'**
  String get pDuckHelp;

  /// No description provided for @pDuckAmount.
  ///
  /// In ru, this message translates to:
  /// **'Сила приглушения'**
  String get pDuckAmount;

  /// No description provided for @pDuckAmountHint.
  ///
  /// In ru, this message translates to:
  /// **'Больше — музыка уходит глубже'**
  String get pDuckAmountHint;

  /// No description provided for @groupRecognition.
  ///
  /// In ru, this message translates to:
  /// **'Распознавание'**
  String get groupRecognition;

  /// No description provided for @pWhisperModel.
  ///
  /// In ru, this message translates to:
  /// **'Модель'**
  String get pWhisperModel;

  /// No description provided for @pWhisperModelHint.
  ///
  /// In ru, this message translates to:
  /// **'Установите модели ниже'**
  String get pWhisperModelHint;

  /// No description provided for @pWhisperModelHelp.
  ///
  /// In ru, this message translates to:
  /// **'Tiny и Base работают быстро даже на процессоре, но ошибаются чаще. Small — хороший выбор для русского. Medium и Large v3 Turbo точнее всего, но без видеокарты работают медленно (Turbo на процессоре — примерно в реальном времени).'**
  String get pWhisperModelHelp;

  /// No description provided for @languageAuto.
  ///
  /// In ru, this message translates to:
  /// **'авто'**
  String get languageAuto;

  /// No description provided for @pTranscriptFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат'**
  String get pTranscriptFormat;

  /// No description provided for @pTranscriptFormatHint.
  ///
  /// In ru, this message translates to:
  /// **'SRT — субтитры со временем, текст — сплошной'**
  String get pTranscriptFormatHint;

  /// No description provided for @formatSrt.
  ///
  /// In ru, this message translates to:
  /// **'Субтитры SRT'**
  String get formatSrt;

  /// No description provided for @formatText.
  ///
  /// In ru, this message translates to:
  /// **'Текст'**
  String get formatText;

  /// No description provided for @pUseGpu.
  ///
  /// In ru, this message translates to:
  /// **'Видеокарта'**
  String get pUseGpu;

  /// No description provided for @pUseGpuHint.
  ///
  /// In ru, this message translates to:
  /// **'Намного быстрее, если сборка и драйверы это поддерживают'**
  String get pUseGpuHint;

  /// No description provided for @groupNeedsBuild.
  ///
  /// In ru, this message translates to:
  /// **'Нужна другая сборка ffmpeg'**
  String get groupNeedsBuild;

  /// No description provided for @whisperFilterMissing.
  ///
  /// In ru, this message translates to:
  /// **'В этой сборке ffmpeg нет фильтра whisper'**
  String get whisperFilterMissing;

  /// No description provided for @whisperFilterHelp.
  ///
  /// In ru, this message translates to:
  /// **'Распознавание речи встроено в ffmpeg начиная с версии 8.0, но только в сборки с библиотекой whisper.cpp. Для Windows она есть в полной сборке gyan.dev (Full) — выберите её в «Компонентах». В сборках BtbN и большинстве системных пакетов Linux её пока нет.'**
  String get whisperFilterHelp;

  /// No description provided for @whisperNeedsModel.
  ///
  /// In ru, this message translates to:
  /// **'Установите хотя бы одну модель Whisper'**
  String get whisperNeedsModel;

  /// No description provided for @abCompare.
  ///
  /// In ru, this message translates to:
  /// **'Сравнить A/B'**
  String get abCompare;

  /// No description provided for @abTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение с оригиналом'**
  String get abTitle;

  /// No description provided for @abIntro.
  ///
  /// In ru, this message translates to:
  /// **'Будет обработан короткий фрагмент с текущими настройками — затем его можно сравнить с оригиналом шторкой, рядом или переключением.'**
  String get abIntro;

  /// No description provided for @abRendering.
  ///
  /// In ru, this message translates to:
  /// **'Обработка фрагмента…'**
  String get abRendering;

  /// No description provided for @abRender.
  ///
  /// In ru, this message translates to:
  /// **'Обработать фрагмент'**
  String get abRender;

  /// No description provided for @abRerender.
  ///
  /// In ru, this message translates to:
  /// **'Обработать заново'**
  String get abRerender;

  /// No description provided for @abFrom.
  ///
  /// In ru, this message translates to:
  /// **'С'**
  String get abFrom;

  /// No description provided for @abOriginal.
  ///
  /// In ru, this message translates to:
  /// **'Оригинал'**
  String get abOriginal;

  /// No description provided for @abResult.
  ///
  /// In ru, this message translates to:
  /// **'Результат'**
  String get abResult;

  /// No description provided for @abSideBySide.
  ///
  /// In ru, this message translates to:
  /// **'Рядом'**
  String get abSideBySide;

  /// No description provided for @abToggle.
  ///
  /// In ru, this message translates to:
  /// **'Переключение'**
  String get abToggle;

  /// No description provided for @abToggleHint.
  ///
  /// In ru, this message translates to:
  /// **'Щёлкайте по видео, чтобы переключаться между оригиналом и результатом.'**
  String get abToggleHint;

  /// No description provided for @abSizeNote.
  ///
  /// In ru, this message translates to:
  /// **'Фрагмент: {size}; весь файл будет около {total}.'**
  String abSizeNote(String size, String total);

  /// No description provided for @groupSubSource.
  ///
  /// In ru, this message translates to:
  /// **'Какие субтитры'**
  String get groupSubSource;

  /// No description provided for @embeddedTrack.
  ///
  /// In ru, this message translates to:
  /// **'Дорожка из файла'**
  String get embeddedTrack;

  /// No description provided for @subFileFromDisk.
  ///
  /// In ru, this message translates to:
  /// **'Файл субтитров'**
  String get subFileFromDisk;

  /// No description provided for @subFileHint.
  ///
  /// In ru, this message translates to:
  /// **'SRT, ASS, VTT — отдельный файл'**
  String get subFileHint;

  /// No description provided for @burnChooseSubs.
  ///
  /// In ru, this message translates to:
  /// **'Выберите дорожку или файл субтитров'**
  String get burnChooseSubs;

  /// No description provided for @burnBitmapNote.
  ///
  /// In ru, this message translates to:
  /// **'В файле только графические субтитры (PGS/DVD) — вшить можно только текстовые. Выберите файл SRT/ASS.'**
  String get burnBitmapNote;

  /// No description provided for @pCharset.
  ///
  /// In ru, this message translates to:
  /// **'Кодировка'**
  String get pCharset;

  /// No description provided for @pCharsetHint.
  ///
  /// In ru, this message translates to:
  /// **'Если вместо букв «кракозябры» — выберите CP1251'**
  String get pCharsetHint;

  /// No description provided for @groupSubStyle.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get groupSubStyle;

  /// No description provided for @pSubFontSizeHint.
  ///
  /// In ru, this message translates to:
  /// **'«авто» — как задано в файле'**
  String get pSubFontSizeHint;

  /// No description provided for @pSubColorHint.
  ///
  /// In ru, this message translates to:
  /// **'Цвет текста субтитров'**
  String get pSubColorHint;

  /// No description provided for @pSubPositionHint.
  ///
  /// In ru, this message translates to:
  /// **'Где показывать строки'**
  String get pSubPositionHint;

  /// No description provided for @pSubMarginHint.
  ///
  /// In ru, this message translates to:
  /// **'Отступ от края кадра в пикселях'**
  String get pSubMarginHint;

  /// No description provided for @groupExistingSubs.
  ///
  /// In ru, this message translates to:
  /// **'Дорожки в файле'**
  String get groupExistingSubs;

  /// No description provided for @noSubtitleTracks.
  ///
  /// In ru, this message translates to:
  /// **'В файле нет субтитров'**
  String get noSubtitleTracks;

  /// No description provided for @subKeep.
  ///
  /// In ru, this message translates to:
  /// **'останется'**
  String get subKeep;

  /// No description provided for @subRemove.
  ///
  /// In ru, this message translates to:
  /// **'будет удалена'**
  String get subRemove;

  /// No description provided for @extractSubs.
  ///
  /// In ru, this message translates to:
  /// **'Извлечь субтитры'**
  String get extractSubs;

  /// No description provided for @flagDefault.
  ///
  /// In ru, this message translates to:
  /// **'по умолчанию'**
  String get flagDefault;

  /// No description provided for @flagForced.
  ///
  /// In ru, this message translates to:
  /// **'принудительные'**
  String get flagForced;

  /// No description provided for @groupAddSubs.
  ///
  /// In ru, this message translates to:
  /// **'Добавить дорожки'**
  String get groupAddSubs;

  /// No description provided for @addSubsHint.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте файлы SRT/ASS/VTT — они станут дорожками, которые можно включать в плеере. Видео и звук не перекодируются.'**
  String get addSubsHint;

  /// No description provided for @trackTitle.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get trackTitle;

  /// No description provided for @subContainerHint.
  ///
  /// In ru, this message translates to:
  /// **'MKV хранит любые субтитры; MP4 — только текстовые (mov_text)'**
  String get subContainerHint;

  /// No description provided for @bitmapSubsInMp4.
  ///
  /// In ru, this message translates to:
  /// **'Графические субтитры (PGS/DVD) нельзя сохранить в MP4/MOV — выберите MKV или снимите эти дорожки'**
  String get bitmapSubsInMp4;

  /// No description provided for @groupSubConvert.
  ///
  /// In ru, this message translates to:
  /// **'Преобразование'**
  String get groupSubConvert;

  /// No description provided for @notASubtitleFile.
  ///
  /// In ru, this message translates to:
  /// **'Это не файл субтитров — откройте SRT, ASS или VTT'**
  String get notASubtitleFile;

  /// No description provided for @pSubFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат'**
  String get pSubFormat;

  /// No description provided for @pSubFormatHint.
  ///
  /// In ru, this message translates to:
  /// **'SRT — самый совместимый, ASS — со стилями, WebVTT — для веба'**
  String get pSubFormatHint;

  /// No description provided for @pSubShift.
  ///
  /// In ru, this message translates to:
  /// **'Сдвиг'**
  String get pSubShift;

  /// No description provided for @pSubShiftHint.
  ///
  /// In ru, this message translates to:
  /// **'Положительный — позже, отрицательный — раньше'**
  String get pSubShiftHint;

  /// No description provided for @pSubRetime.
  ///
  /// In ru, this message translates to:
  /// **'Пересчёт частоты кадров'**
  String get pSubRetime;

  /// No description provided for @pSubRetimeHint.
  ///
  /// In ru, this message translates to:
  /// **'Если субтитры постепенно «уезжают»'**
  String get pSubRetimeHint;

  /// No description provided for @pSubRetimeHelp.
  ///
  /// In ru, this message translates to:
  /// **'Субтитры, сделанные для версии 25 к/с, к версии 23,976 к/с отстают тем сильнее, чем дальше от начала (и наоборот). Пересчёт растягивает или сжимает все времена в нужное число раз. Если рассинхрон одинаковый на всём фильме — нужен только сдвиг.'**
  String get pSubRetimeHelp;

  /// No description provided for @subShiftExample.
  ///
  /// In ru, this message translates to:
  /// **'Строка с 0:01.000 начнётся в {t} с'**
  String subShiftExample(String t);

  /// No description provided for @groupImageFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат картинки'**
  String get groupImageFormat;

  /// No description provided for @pImageFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат'**
  String get pImageFormat;

  /// No description provided for @imgPngHint.
  ///
  /// In ru, this message translates to:
  /// **'Без потерь, крупный файл; поддерживает прозрачность'**
  String get imgPngHint;

  /// No description provided for @imgJpgHint.
  ///
  /// In ru, this message translates to:
  /// **'Самый совместимый, для фото'**
  String get imgJpgHint;

  /// No description provided for @imgWebpHint.
  ///
  /// In ru, this message translates to:
  /// **'Меньше JPEG при том же качестве; понимают все браузеры'**
  String get imgWebpHint;

  /// No description provided for @imgAvifHint.
  ///
  /// In ru, this message translates to:
  /// **'Ещё меньше WebP; кодируется медленно'**
  String get imgAvifHint;

  /// No description provided for @imgJxlHint.
  ///
  /// In ru, this message translates to:
  /// **'JPEG XL — очень эффективный, поддерживается пока не везде'**
  String get imgJxlHint;

  /// No description provided for @pImageQuality.
  ///
  /// In ru, this message translates to:
  /// **'Качество'**
  String get pImageQuality;

  /// No description provided for @pImageQualityHint.
  ///
  /// In ru, this message translates to:
  /// **'Больше — лучше и крупнее; 100 — без потерь (WebP, JPEG XL)'**
  String get pImageQualityHint;

  /// No description provided for @lossless.
  ///
  /// In ru, this message translates to:
  /// **'без потерь'**
  String get lossless;

  /// No description provided for @groupFrames.
  ///
  /// In ru, this message translates to:
  /// **'Кадры'**
  String get groupFrames;

  /// No description provided for @pFramesMode.
  ///
  /// In ru, this message translates to:
  /// **'Какие кадры'**
  String get pFramesMode;

  /// No description provided for @framesSingle.
  ///
  /// In ru, this message translates to:
  /// **'Один кадр'**
  String get framesSingle;

  /// No description provided for @framesBest.
  ///
  /// In ru, this message translates to:
  /// **'Лучший кадр'**
  String get framesBest;

  /// No description provided for @framesEvery.
  ///
  /// In ru, this message translates to:
  /// **'Через интервал'**
  String get framesEvery;

  /// No description provided for @framesN.
  ///
  /// In ru, this message translates to:
  /// **'N штук'**
  String get framesN;

  /// No description provided for @framesScenes.
  ///
  /// In ru, this message translates to:
  /// **'На смене сцен'**
  String get framesScenes;

  /// No description provided for @framesSingleHint.
  ///
  /// In ru, this message translates to:
  /// **'Кадр в выбранный момент — для обложки или скриншота'**
  String get framesSingleHint;

  /// No description provided for @framesBestHint.
  ///
  /// In ru, this message translates to:
  /// **'Самый характерный кадр из первых секунд (фильтр thumbnail)'**
  String get framesBestHint;

  /// No description provided for @framesEveryHint.
  ///
  /// In ru, this message translates to:
  /// **'Кадры через равные промежутки времени'**
  String get framesEveryHint;

  /// No description provided for @framesCountHint.
  ///
  /// In ru, this message translates to:
  /// **'Заданное число кадров, равномерно по всему файлу'**
  String get framesCountHint;

  /// No description provided for @framesScenesHint.
  ///
  /// In ru, this message translates to:
  /// **'Первый кадр каждой новой сцены'**
  String get framesScenesHint;

  /// No description provided for @pFrameAt.
  ///
  /// In ru, this message translates to:
  /// **'Момент'**
  String get pFrameAt;

  /// No description provided for @pFrameAtHint.
  ///
  /// In ru, this message translates to:
  /// **'Можно выбрать ползунком под кадром'**
  String get pFrameAtHint;

  /// No description provided for @pFramesInterval.
  ///
  /// In ru, this message translates to:
  /// **'Интервал'**
  String get pFramesInterval;

  /// No description provided for @pFramesNumber.
  ///
  /// In ru, this message translates to:
  /// **'Сколько кадров'**
  String get pFramesNumber;

  /// No description provided for @pFramesNumberHint.
  ///
  /// In ru, this message translates to:
  /// **'Равномерно по длительности'**
  String get pFramesNumberHint;

  /// No description provided for @pImageWidth.
  ///
  /// In ru, this message translates to:
  /// **'Ширина'**
  String get pImageWidth;

  /// No description provided for @pImageWidthHint.
  ///
  /// In ru, this message translates to:
  /// **'Высота подбирается по пропорциям'**
  String get pImageWidthHint;

  /// No description provided for @framesCount.
  ///
  /// In ru, this message translates to:
  /// **'Получится картинок: {n}'**
  String framesCount(int n);

  /// No description provided for @framesSceneCount.
  ///
  /// In ru, this message translates to:
  /// **'Число картинок зависит от числа сцен'**
  String get framesSceneCount;

  /// No description provided for @groupSheet.
  ///
  /// In ru, this message translates to:
  /// **'Раскадровка'**
  String get groupSheet;

  /// No description provided for @pColumns.
  ///
  /// In ru, this message translates to:
  /// **'Столбцов'**
  String get pColumns;

  /// No description provided for @pColumnsHint.
  ///
  /// In ru, this message translates to:
  /// **'Кадров в строке'**
  String get pColumnsHint;

  /// No description provided for @pRows.
  ///
  /// In ru, this message translates to:
  /// **'Строк'**
  String get pRows;

  /// No description provided for @pRowsHint.
  ///
  /// In ru, this message translates to:
  /// **'Всего кадров = столбцы × строки'**
  String get pRowsHint;

  /// No description provided for @pThumbWidth.
  ///
  /// In ru, this message translates to:
  /// **'Ширина кадра'**
  String get pThumbWidth;

  /// No description provided for @pThumbWidthHint.
  ///
  /// In ru, this message translates to:
  /// **'Каждой миниатюры'**
  String get pThumbWidthHint;

  /// No description provided for @pTimestamps.
  ///
  /// In ru, this message translates to:
  /// **'Время на кадрах'**
  String get pTimestamps;

  /// No description provided for @pTimestampsHint.
  ///
  /// In ru, this message translates to:
  /// **'Подпись времени в углу каждой миниатюры'**
  String get pTimestampsHint;

  /// No description provided for @pBackground.
  ///
  /// In ru, this message translates to:
  /// **'Фон'**
  String get pBackground;

  /// No description provided for @pBackgroundHint.
  ///
  /// In ru, this message translates to:
  /// **'Цвет промежутков между кадрами'**
  String get pBackgroundHint;

  /// No description provided for @colorGray.
  ///
  /// In ru, this message translates to:
  /// **'серый'**
  String get colorGray;

  /// No description provided for @sheetSize.
  ///
  /// In ru, this message translates to:
  /// **'Ширина картинки: {width}, кадров: {count}'**
  String sheetSize(String width, String count);

  /// No description provided for @groupImages.
  ///
  /// In ru, this message translates to:
  /// **'Картинки'**
  String get groupImages;

  /// No description provided for @groupSlides.
  ///
  /// In ru, this message translates to:
  /// **'Слайды'**
  String get groupSlides;

  /// No description provided for @slideshowOnlyImages.
  ///
  /// In ru, this message translates to:
  /// **'«{name}» — не картинка; для видео используйте «Склейку»'**
  String slideshowOnlyImages(String name);

  /// No description provided for @pFrameSize.
  ///
  /// In ru, this message translates to:
  /// **'Размер кадра'**
  String get pFrameSize;

  /// No description provided for @pFrameSizeHint.
  ///
  /// In ru, this message translates to:
  /// **'Картинки вписываются в этот кадр'**
  String get pFrameSizeHint;

  /// No description provided for @pPerImage.
  ///
  /// In ru, this message translates to:
  /// **'Время на картинку'**
  String get pPerImage;

  /// No description provided for @pPerImageHint.
  ///
  /// In ru, this message translates to:
  /// **'Сколько секунд показывать каждую'**
  String get pPerImageHint;

  /// No description provided for @hardCut.
  ///
  /// In ru, this message translates to:
  /// **'Без перехода'**
  String get hardCut;

  /// No description provided for @pKenBurns.
  ///
  /// In ru, this message translates to:
  /// **'Плавный наезд'**
  String get pKenBurns;

  /// No description provided for @pKenBurnsHint.
  ///
  /// In ru, this message translates to:
  /// **'Эффект Кена Бёрнса: картинки медленно приближаются'**
  String get pKenBurnsHint;

  /// No description provided for @slideshowMusicHint.
  ///
  /// In ru, this message translates to:
  /// **'Необязательно; обрежется по длине слайд-шоу'**
  String get slideshowMusicHint;

  /// No description provided for @pFitToAudio.
  ///
  /// In ru, this message translates to:
  /// **'Подогнать под музыку'**
  String get pFitToAudio;

  /// No description provided for @pFitToAudioHint.
  ///
  /// In ru, this message translates to:
  /// **'Время на картинку рассчитывается так, чтобы слайд-шоу длилось столько же, сколько музыка'**
  String get pFitToAudioHint;

  /// No description provided for @pCoverSource.
  ///
  /// In ru, this message translates to:
  /// **'Картинка'**
  String get pCoverSource;

  /// No description provided for @pCoverSourceHint.
  ///
  /// In ru, this message translates to:
  /// **'Что показывать, пока звучит звук'**
  String get pCoverSourceHint;

  /// No description provided for @coverEmbedded.
  ///
  /// In ru, this message translates to:
  /// **'Обложка из файла'**
  String get coverEmbedded;

  /// No description provided for @coverFile.
  ///
  /// In ru, this message translates to:
  /// **'Своя картинка'**
  String get coverFile;

  /// No description provided for @coverColor.
  ///
  /// In ru, this message translates to:
  /// **'Цвет'**
  String get coverColor;

  /// No description provided for @chooseCoverImage.
  ///
  /// In ru, this message translates to:
  /// **'Выберите картинку'**
  String get chooseCoverImage;

  /// No description provided for @pWaveOverlay.
  ///
  /// In ru, this message translates to:
  /// **'Волна поверх'**
  String get pWaveOverlay;

  /// No description provided for @pWaveOverlayHint.
  ///
  /// In ru, this message translates to:
  /// **'Анимированная звуковая волна внизу кадра'**
  String get pWaveOverlayHint;

  /// No description provided for @groupVisual.
  ///
  /// In ru, this message translates to:
  /// **'Визуализация'**
  String get groupVisual;

  /// No description provided for @pVisualKind.
  ///
  /// In ru, this message translates to:
  /// **'Вид'**
  String get pVisualKind;

  /// No description provided for @visWaves.
  ///
  /// In ru, this message translates to:
  /// **'Волна'**
  String get visWaves;

  /// No description provided for @visScope.
  ///
  /// In ru, this message translates to:
  /// **'Вектороскоп'**
  String get visScope;

  /// No description provided for @visCqt.
  ///
  /// In ru, this message translates to:
  /// **'Ноты'**
  String get visCqt;

  /// No description provided for @visWavesHint.
  ///
  /// In ru, this message translates to:
  /// **'Осциллограмма звука в реальном времени'**
  String get visWavesHint;

  /// No description provided for @visSpectrumHint.
  ///
  /// In ru, this message translates to:
  /// **'Бегущая спектрограмма'**
  String get visSpectrumHint;

  /// No description provided for @visScopeHint.
  ///
  /// In ru, this message translates to:
  /// **'Стереокартина: ширина и фаза звука'**
  String get visScopeHint;

  /// No description provided for @visCqtHint.
  ///
  /// In ru, this message translates to:
  /// **'Спектр по нотам с клавиатурой пианино'**
  String get visCqtHint;

  /// No description provided for @pMaxSide.
  ///
  /// In ru, this message translates to:
  /// **'Максимальная сторона'**
  String get pMaxSide;

  /// No description provided for @pMaxSideHint.
  ///
  /// In ru, this message translates to:
  /// **'Уменьшить, если больше; никогда не увеличивает'**
  String get pMaxSideHint;

  /// No description provided for @pStripMetadata.
  ///
  /// In ru, this message translates to:
  /// **'Удалить метаданные'**
  String get pStripMetadata;

  /// No description provided for @pStripMetadataHint.
  ///
  /// In ru, this message translates to:
  /// **'EXIF, GPS-координаты, модель камеры'**
  String get pStripMetadataHint;

  /// No description provided for @groupTags.
  ///
  /// In ru, this message translates to:
  /// **'Теги'**
  String get groupTags;

  /// No description provided for @tagTitle.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get tagTitle;

  /// No description provided for @tagArtist.
  ///
  /// In ru, this message translates to:
  /// **'Исполнитель'**
  String get tagArtist;

  /// No description provided for @tagAlbumArtist.
  ///
  /// In ru, this message translates to:
  /// **'Исполнитель альбома'**
  String get tagAlbumArtist;

  /// No description provided for @tagAlbum.
  ///
  /// In ru, this message translates to:
  /// **'Альбом'**
  String get tagAlbum;

  /// No description provided for @tagDate.
  ///
  /// In ru, this message translates to:
  /// **'Год / дата'**
  String get tagDate;

  /// No description provided for @tagGenre.
  ///
  /// In ru, this message translates to:
  /// **'Жанр'**
  String get tagGenre;

  /// No description provided for @tagTrack.
  ///
  /// In ru, this message translates to:
  /// **'Номер трека'**
  String get tagTrack;

  /// No description provided for @tagDisc.
  ///
  /// In ru, this message translates to:
  /// **'Номер диска'**
  String get tagDisc;

  /// No description provided for @tagComposer.
  ///
  /// In ru, this message translates to:
  /// **'Композитор'**
  String get tagComposer;

  /// No description provided for @tagComment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get tagComment;

  /// No description provided for @tagDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get tagDescription;

  /// No description provided for @tagCopyright.
  ///
  /// In ru, this message translates to:
  /// **'Авторские права'**
  String get tagCopyright;

  /// No description provided for @customTagKey.
  ///
  /// In ru, this message translates to:
  /// **'Свой тег (латиницей)'**
  String get customTagKey;

  /// No description provided for @addTag.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get addTag;

  /// No description provided for @pClearTags.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все остальные теги'**
  String get pClearTags;

  /// No description provided for @pClearTagsHint.
  ///
  /// In ru, this message translates to:
  /// **'Оставить только то, что заполнено выше'**
  String get pClearTagsHint;

  /// No description provided for @groupStreamLanguages.
  ///
  /// In ru, this message translates to:
  /// **'Языки дорожек'**
  String get groupStreamLanguages;

  /// No description provided for @groupCover.
  ///
  /// In ru, this message translates to:
  /// **'Обложка'**
  String get groupCover;

  /// No description provided for @pCoverAction.
  ///
  /// In ru, this message translates to:
  /// **'Что сделать'**
  String get pCoverAction;

  /// No description provided for @coverPresent.
  ///
  /// In ru, this message translates to:
  /// **'В файле есть обложка'**
  String get coverPresent;

  /// No description provided for @noCover.
  ///
  /// In ru, this message translates to:
  /// **'Обложки нет'**
  String get noCover;

  /// No description provided for @coverSet.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get coverSet;

  /// No description provided for @coverReplace.
  ///
  /// In ru, this message translates to:
  /// **'Заменить'**
  String get coverReplace;

  /// No description provided for @coverRemove.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get coverRemove;

  /// No description provided for @coverImageHint.
  ///
  /// In ru, this message translates to:
  /// **'Лучше квадратная JPEG или PNG, 500–1500 px'**
  String get coverImageHint;

  /// No description provided for @saveCover.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить обложку'**
  String get saveCover;

  /// No description provided for @groupChapters.
  ///
  /// In ru, this message translates to:
  /// **'Главы'**
  String get groupChapters;

  /// No description provided for @noChapters.
  ///
  /// In ru, this message translates to:
  /// **'Глав нет — добавьте или вставьте список из описания YouTube'**
  String get noChapters;

  /// No description provided for @chapterTitle.
  ///
  /// In ru, this message translates to:
  /// **'Название главы'**
  String get chapterTitle;

  /// No description provided for @chapterN.
  ///
  /// In ru, this message translates to:
  /// **'Глава {n}'**
  String chapterN(int n);

  /// No description provided for @addChapter.
  ///
  /// In ru, this message translates to:
  /// **'Добавить главу'**
  String get addChapter;

  /// No description provided for @removeAllChapters.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все'**
  String get removeAllChapters;

  /// No description provided for @importChapters.
  ///
  /// In ru, this message translates to:
  /// **'Вставить список'**
  String get importChapters;

  /// No description provided for @importAction.
  ///
  /// In ru, this message translates to:
  /// **'Вставить'**
  String get importAction;

  /// No description provided for @importChaptersHint.
  ///
  /// In ru, this message translates to:
  /// **'По строке на главу: время и название, как в описании YouTube'**
  String get importChaptersHint;

  /// No description provided for @copyChapters.
  ///
  /// In ru, this message translates to:
  /// **'Копировать для YouTube'**
  String get copyChapters;

  /// No description provided for @groupRepair.
  ///
  /// In ru, this message translates to:
  /// **'Починка'**
  String get groupRepair;

  /// No description provided for @pRepairMode.
  ///
  /// In ru, this message translates to:
  /// **'Что исправить'**
  String get pRepairMode;

  /// No description provided for @repairRemux.
  ///
  /// In ru, this message translates to:
  /// **'Пересобрать'**
  String get repairRemux;

  /// No description provided for @repairOffset.
  ///
  /// In ru, this message translates to:
  /// **'Сдвинуть звук'**
  String get repairOffset;

  /// No description provided for @repairReencode.
  ///
  /// In ru, this message translates to:
  /// **'Перекодировать'**
  String get repairReencode;

  /// No description provided for @repairRemuxHint.
  ///
  /// In ru, this message translates to:
  /// **'Не перематывается, неверная длительность, ошибки при открытии — без потерь'**
  String get repairRemuxHint;

  /// No description provided for @repairOffsetHint.
  ///
  /// In ru, this message translates to:
  /// **'Звук опережает или отстаёт на одну и ту же величину — без потерь'**
  String get repairOffsetHint;

  /// No description provided for @repairReencodeHint.
  ///
  /// In ru, this message translates to:
  /// **'Рассинхрон нарастает, дёргается картинка, файл повреждён — пересчёт с постоянной частотой кадров'**
  String get repairReencodeHint;

  /// No description provided for @pRepairModeHelp.
  ///
  /// In ru, this message translates to:
  /// **'«Пересобрать» заново упаковывает потоки, пересчитывая временные метки и выбрасывая битые пакеты — помогает чаще всего и ничего не перекодирует. «Сдвинуть звук» — если рассинхрон одинаковый по всему файлу. «Перекодировать» — для записей с переменной частотой кадров (с телефона, записи экрана), у которых звук постепенно уезжает: картинка приводится к постоянной частоте, звук подстраивается под время.'**
  String get pRepairModeHelp;

  /// No description provided for @pAudioOffset.
  ///
  /// In ru, this message translates to:
  /// **'Сдвиг звука'**
  String get pAudioOffset;

  /// No description provided for @pAudioOffsetHint.
  ///
  /// In ru, this message translates to:
  /// **'Плюс — звук позже, минус — раньше'**
  String get pAudioOffsetHint;

  /// No description provided for @repairFpsHint.
  ///
  /// In ru, this message translates to:
  /// **'Постоянная частота кадров результата'**
  String get repairFpsHint;

  /// No description provided for @repairNeedsAv.
  ///
  /// In ru, this message translates to:
  /// **'Для сдвига нужны и видео, и звук'**
  String get repairNeedsAv;

  /// No description provided for @groupFaststart.
  ///
  /// In ru, this message translates to:
  /// **'Быстрый старт'**
  String get groupFaststart;

  /// No description provided for @moovAtEnd.
  ///
  /// In ru, this message translates to:
  /// **'Индекс в конце файла — в браузере видео начнёт играть только после полной загрузки'**
  String get moovAtEnd;

  /// No description provided for @moovAtStart.
  ///
  /// In ru, this message translates to:
  /// **'Индекс уже в начале — видео стартует сразу'**
  String get moovAtStart;

  /// No description provided for @moovUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось определить положение индекса'**
  String get moovUnknown;

  /// No description provided for @faststartExplained.
  ///
  /// In ru, this message translates to:
  /// **'Перенос индекса (moov) в начало MP4/MOV без перекодирования: видео в браузере и мессенджерах начинает играть до окончания загрузки.'**
  String get faststartExplained;

  /// No description provided for @faststartOnlyMp4.
  ///
  /// In ru, this message translates to:
  /// **'Работает только для MP4, MOV и M4A'**
  String get faststartOnlyMp4;

  /// No description provided for @faststartAlready.
  ///
  /// In ru, this message translates to:
  /// **'Файлу это уже не нужно'**
  String get faststartAlready;

  /// No description provided for @opConvert.
  ///
  /// In ru, this message translates to:
  /// **'Конвертация по пресету'**
  String get opConvert;

  /// No description provided for @opNormalize.
  ///
  /// In ru, this message translates to:
  /// **'Нормализация громкости'**
  String get opNormalize;

  /// No description provided for @opVertical.
  ///
  /// In ru, this message translates to:
  /// **'Вертикальное 9:16'**
  String get opVertical;

  /// No description provided for @opScale.
  ///
  /// In ru, this message translates to:
  /// **'Уменьшить до высоты'**
  String get opScale;

  /// No description provided for @opDenoise.
  ///
  /// In ru, this message translates to:
  /// **'Шумоподавление звука'**
  String get opDenoise;

  /// No description provided for @opFade.
  ///
  /// In ru, this message translates to:
  /// **'Появление и исчезание'**
  String get opFade;

  /// No description provided for @opText.
  ///
  /// In ru, this message translates to:
  /// **'Надпись'**
  String get opText;

  /// No description provided for @opLogo.
  ///
  /// In ru, this message translates to:
  /// **'Логотип'**
  String get opLogo;

  /// No description provided for @opBurnSidecar.
  ///
  /// In ru, this message translates to:
  /// **'Вшить субтитры рядом с файлом'**
  String get opBurnSidecar;

  /// No description provided for @opStripMetadata.
  ///
  /// In ru, this message translates to:
  /// **'Удалить метаданные'**
  String get opStripMetadata;

  /// No description provided for @opFaststart.
  ///
  /// In ru, this message translates to:
  /// **'Faststart для MP4'**
  String get opFaststart;

  /// No description provided for @opExtractAudio.
  ///
  /// In ru, this message translates to:
  /// **'Только звук'**
  String get opExtractAudio;

  /// No description provided for @opBurnSidecarHint.
  ///
  /// In ru, this message translates to:
  /// **'Если рядом лежит файл с тем же именем (.srt/.ass/.vtt), он будет вшит; иначе шаг пропускается.'**
  String get opBurnSidecarHint;

  /// No description provided for @opDenoiseHint.
  ///
  /// In ru, this message translates to:
  /// **'RNNoise, если установлена модель (раздел «Компоненты»), иначе обычное FFT-шумоподавление.'**
  String get opDenoiseHint;

  /// No description provided for @newRecipe.
  ///
  /// In ru, this message translates to:
  /// **'Новый рецепт'**
  String get newRecipe;

  /// No description provided for @newRecipeName.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт {n}'**
  String newRecipeName(int n);

  /// No description provided for @noRecipes.
  ///
  /// In ru, this message translates to:
  /// **'Рецептов пока нет'**
  String get noRecipes;

  /// No description provided for @recipesExplained.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт — это цепочка действий, которую можно применить к любому числу файлов: например, «вертикальное видео → нормализация → faststart». Добавьте шаги кнопкой «+».'**
  String get recipesExplained;

  /// No description provided for @tplReels.
  ///
  /// In ru, this message translates to:
  /// **'Для Reels и Shorts'**
  String get tplReels;

  /// No description provided for @tplPodcast.
  ///
  /// In ru, this message translates to:
  /// **'Подкаст из видео'**
  String get tplPodcast;

  /// No description provided for @tplTelegram.
  ///
  /// In ru, this message translates to:
  /// **'Для Telegram с субтитрами'**
  String get tplTelegram;

  /// No description provided for @recipeName.
  ///
  /// In ru, this message translates to:
  /// **'Название рецепта'**
  String get recipeName;

  /// No description provided for @runRecipe.
  ///
  /// In ru, this message translates to:
  /// **'Применить к файлам'**
  String get runRecipe;

  /// No description provided for @groupRecipeSteps.
  ///
  /// In ru, this message translates to:
  /// **'Шаги'**
  String get groupRecipeSteps;

  /// No description provided for @addStep.
  ///
  /// In ru, this message translates to:
  /// **'Добавить шаг'**
  String get addStep;

  /// No description provided for @recipeChainNote.
  ///
  /// In ru, this message translates to:
  /// **'Каждый шаг получает результат предыдущего. Промежуточные файлы хранятся во временной папке задачи и кодируются с высоким качеством; формат результата задаёт последний шаг с форматом (конвертация или «только звук»), иначе — как у исходника.'**
  String get recipeChainNote;

  /// No description provided for @pPreset.
  ///
  /// In ru, this message translates to:
  /// **'Пресет'**
  String get pPreset;

  /// No description provided for @pRecipePresetHint.
  ///
  /// In ru, this message translates to:
  /// **'Встроенный или ваш пресет конвертации'**
  String get pRecipePresetHint;

  /// No description provided for @pRecipeScaleHint.
  ///
  /// In ru, this message translates to:
  /// **'Файлы меньше этого размера не увеличиваются'**
  String get pRecipeScaleHint;

  /// No description provided for @pRecipeFadeHint.
  ///
  /// In ru, this message translates to:
  /// **'Длительность появления и исчезания'**
  String get pRecipeFadeHint;

  /// No description provided for @pRecipeAudioHint.
  ///
  /// In ru, this message translates to:
  /// **'Формат звукового файла'**
  String get pRecipeAudioHint;

  /// No description provided for @recipeEmpty.
  ///
  /// In ru, this message translates to:
  /// **'В рецепте нет шагов'**
  String get recipeEmpty;

  /// No description provided for @recipePresetMissing.
  ///
  /// In ru, this message translates to:
  /// **'Пресет рецепта не найден'**
  String get recipePresetMissing;

  /// No description provided for @recipeNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт не найден'**
  String get recipeNotFound;

  /// No description provided for @groupBatchAction.
  ///
  /// In ru, this message translates to:
  /// **'Что сделать'**
  String get groupBatchAction;

  /// No description provided for @pBatchAction.
  ///
  /// In ru, this message translates to:
  /// **'Действие'**
  String get pBatchAction;

  /// No description provided for @pBatchActionHint.
  ///
  /// In ru, this message translates to:
  /// **'Пресет конвертации или ваш рецепт'**
  String get pBatchActionHint;

  /// No description provided for @pBatchRecipeHint.
  ///
  /// In ru, this message translates to:
  /// **'Цепочка действий из раздела «Рецепты»'**
  String get pBatchRecipeHint;

  /// No description provided for @groupBatchFiles.
  ///
  /// In ru, this message translates to:
  /// **'Файлы: {n}'**
  String groupBatchFiles(int n);

  /// No description provided for @addFolder.
  ///
  /// In ru, this message translates to:
  /// **'Папка'**
  String get addFolder;

  /// No description provided for @clearList.
  ///
  /// In ru, this message translates to:
  /// **'Очистить список'**
  String get clearList;

  /// No description provided for @pRecursive.
  ///
  /// In ru, this message translates to:
  /// **'С вложенными папками'**
  String get pRecursive;

  /// No description provided for @pRecursiveHint.
  ///
  /// In ru, this message translates to:
  /// **'Искать файлы и во вложенных папках'**
  String get pRecursiveHint;

  /// No description provided for @pFileKind.
  ///
  /// In ru, this message translates to:
  /// **'Какие файлы'**
  String get pFileKind;

  /// No description provided for @pFileKindHint.
  ///
  /// In ru, this message translates to:
  /// **'Остальные будут пропущены'**
  String get pFileKindHint;

  /// No description provided for @kindAll.
  ///
  /// In ru, this message translates to:
  /// **'все медиафайлы'**
  String get kindAll;

  /// No description provided for @kindVideo.
  ///
  /// In ru, this message translates to:
  /// **'видео'**
  String get kindVideo;

  /// No description provided for @kindAudio.
  ///
  /// In ru, this message translates to:
  /// **'звук'**
  String get kindAudio;

  /// No description provided for @kindImages.
  ///
  /// In ru, this message translates to:
  /// **'картинки'**
  String get kindImages;

  /// No description provided for @batchHowTo.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте файлы или папку — каждый файл станет отдельной задачей в очереди.'**
  String get batchHowTo;

  /// No description provided for @groupBatchOutput.
  ///
  /// In ru, this message translates to:
  /// **'Куда сохранять'**
  String get groupBatchOutput;

  /// No description provided for @nextToSource.
  ///
  /// In ru, this message translates to:
  /// **'Рядом с исходными файлами'**
  String get nextToSource;

  /// No description provided for @batchOutDirHint.
  ///
  /// In ru, this message translates to:
  /// **'Существующие файлы не перезаписываются'**
  String get batchOutDirHint;

  /// No description provided for @pKeepStructure.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить структуру папок'**
  String get pKeepStructure;

  /// No description provided for @pKeepStructureHint.
  ///
  /// In ru, this message translates to:
  /// **'Вложенные папки повторяются в папке результата'**
  String get pKeepStructureHint;

  /// No description provided for @batchRun.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в очередь ({n})'**
  String batchRun(int n);

  /// No description provided for @batchQueued.
  ///
  /// In ru, this message translates to:
  /// **'В очередь добавлено: {queued}, пропущено: {skipped}'**
  String batchQueued(int queued, int skipped);

  /// No description provided for @addWatch.
  ///
  /// In ru, this message translates to:
  /// **'Добавить папку'**
  String get addWatch;

  /// No description provided for @noWatches.
  ///
  /// In ru, this message translates to:
  /// **'Папок под наблюдением нет'**
  String get noWatches;

  /// No description provided for @watchExplained.
  ///
  /// In ru, this message translates to:
  /// **'Пока приложение открыто, новые файлы в выбранных папках автоматически обрабатываются пресетом или рецептом. Файл берётся в работу, когда его копирование закончено; уже лежащие в папке файлы не трогаются.'**
  String get watchExplained;

  /// No description provided for @watchHowTo.
  ///
  /// In ru, this message translates to:
  /// **'Например, папка «Входящие» с рецептом «Для Telegram» — бросили видео, через минуту готовый файл в «Входящие/kadra».'**
  String get watchHowTo;

  /// No description provided for @groupWatchLog.
  ///
  /// In ru, this message translates to:
  /// **'Последние события'**
  String get groupWatchLog;

  /// No description provided for @watchQueued.
  ///
  /// In ru, this message translates to:
  /// **'добавлен в очередь'**
  String get watchQueued;

  /// No description provided for @watchFolderPick.
  ///
  /// In ru, this message translates to:
  /// **'Выберите папку'**
  String get watchFolderPick;

  /// No description provided for @watchOutDefault.
  ///
  /// In ru, this message translates to:
  /// **'Подпапка «kadra» в наблюдаемой папке'**
  String get watchOutDefault;

  /// No description provided for @watchOutHint.
  ///
  /// In ru, this message translates to:
  /// **'Папка результатов не отслеживается, чтобы файлы не обрабатывались повторно'**
  String get watchOutHint;

  /// No description provided for @pThenRecipe.
  ///
  /// In ru, this message translates to:
  /// **'После загрузки'**
  String get pThenRecipe;

  /// No description provided for @pThenRecipeHint.
  ///
  /// In ru, this message translates to:
  /// **'Применить рецепт к каждому скачанному файлу'**
  String get pThenRecipeHint;

  /// No description provided for @pRecipeLufs.
  ///
  /// In ru, this message translates to:
  /// **'Целевая громкость'**
  String get pRecipeLufs;

  /// No description provided for @pRecipeLufsHint.
  ///
  /// In ru, this message translates to:
  /// **'−14 — YouTube и стриминг, −16 — подкасты, −23 — ТВ'**
  String get pRecipeLufsHint;

  /// No description provided for @searchCommands.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по названию или команде'**
  String get searchCommands;

  /// No description provided for @commandLogHint.
  ///
  /// In ru, this message translates to:
  /// **'Все задачи очереди с точными командами. Список очищается вместе с историей очереди («Очистить завершённые»).'**
  String get commandLogHint;

  /// No description provided for @noCommands.
  ///
  /// In ru, this message translates to:
  /// **'Команд пока нет'**
  String get noCommands;

  /// No description provided for @editCommand.
  ///
  /// In ru, this message translates to:
  /// **'Открыть в редакторе команд'**
  String get editCommand;

  /// No description provided for @runAgain.
  ///
  /// In ru, this message translates to:
  /// **'Запустить ещё раз'**
  String get runAgain;

  /// No description provided for @templates.
  ///
  /// In ru, this message translates to:
  /// **'Шаблоны'**
  String get templates;

  /// No description provided for @insertInput.
  ///
  /// In ru, this message translates to:
  /// **'Вставить входной файл'**
  String get insertInput;

  /// No description provided for @insertOutput.
  ///
  /// In ru, this message translates to:
  /// **'Вставить файл результата'**
  String get insertOutput;

  /// No description provided for @commandEditorHint.
  ///
  /// In ru, this message translates to:
  /// **'Команда выполняется через очередь, без командной строки: кавычки и пробелы в путях работают на любой системе. Приложение само добавит -nostdin, -y и вывод прогресса, если их нет. Можно писать с «ffmpeg» в начале или без него; для ffprobe — с «ffprobe».'**
  String get commandEditorHint;

  /// No description provided for @cmdErrSyntax.
  ///
  /// In ru, this message translates to:
  /// **'Незакрытая кавычка'**
  String get cmdErrSyntax;

  /// No description provided for @cmdErrEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Команда пустая'**
  String get cmdErrEmpty;

  /// No description provided for @cmdErrExecutable.
  ///
  /// In ru, this message translates to:
  /// **'Здесь выполняются только ffmpeg и ffprobe'**
  String get cmdErrExecutable;

  /// No description provided for @cmdErrNoInput.
  ///
  /// In ru, this message translates to:
  /// **'Нет входного файла (-i)'**
  String get cmdErrNoInput;

  /// No description provided for @groupHelp.
  ///
  /// In ru, this message translates to:
  /// **'Справка ffmpeg'**
  String get groupHelp;

  /// No description provided for @helpNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Имя: scale, libx264, mp4…'**
  String get helpNameHint;

  /// No description provided for @showHelp.
  ///
  /// In ru, this message translates to:
  /// **'Показать'**
  String get showHelp;

  /// No description provided for @tplH264.
  ///
  /// In ru, this message translates to:
  /// **'Перекодировать в H.264 + AAC'**
  String get tplH264;

  /// No description provided for @tplCutCopy.
  ///
  /// In ru, this message translates to:
  /// **'Вырезать кусок без перекодирования'**
  String get tplCutCopy;

  /// No description provided for @tplFrame.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить кадр в PNG'**
  String get tplFrame;

  /// No description provided for @tplMp3.
  ///
  /// In ru, this message translates to:
  /// **'Звук в MP3 (VBR)'**
  String get tplMp3;

  /// No description provided for @tplSpeed2x.
  ///
  /// In ru, this message translates to:
  /// **'Ускорить в 2 раза'**
  String get tplSpeed2x;

  /// No description provided for @tplGif.
  ///
  /// In ru, this message translates to:
  /// **'GIF с палитрой'**
  String get tplGif;

  /// No description provided for @tplProbe.
  ///
  /// In ru, this message translates to:
  /// **'Информация о потоках (ffprobe)'**
  String get tplProbe;

  /// No description provided for @groupFilterChain.
  ///
  /// In ru, this message translates to:
  /// **'Цепочка фильтров'**
  String get groupFilterChain;

  /// No description provided for @videoChain.
  ///
  /// In ru, this message translates to:
  /// **'Видео'**
  String get videoChain;

  /// No description provided for @videoChainHint.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры через запятую: scale=1280:-2,eq=contrast=1.2'**
  String get videoChainHint;

  /// No description provided for @audioChain.
  ///
  /// In ru, this message translates to:
  /// **'Звук'**
  String get audioChain;

  /// No description provided for @audioChainHint.
  ///
  /// In ru, this message translates to:
  /// **'Пусто — звук копируется: volume=2,highpass=f=80'**
  String get audioChainHint;

  /// No description provided for @applyFilters.
  ///
  /// In ru, this message translates to:
  /// **'Применить к предпросмотру'**
  String get applyFilters;

  /// No description provided for @groupFilterList.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры этой сборки: {n}'**
  String groupFilterList(int n);

  /// No description provided for @searchFilters.
  ///
  /// In ru, this message translates to:
  /// **'Поиск фильтра'**
  String get searchFilters;

  /// No description provided for @addFilter.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в цепочку'**
  String get addFilter;

  /// No description provided for @cmdErrPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'В команде остались заготовки — укажите входной файл и файл результата кнопками «Вставить…»'**
  String get cmdErrPlaceholder;

  /// No description provided for @startRecording.
  ///
  /// In ru, this message translates to:
  /// **'Начать запись'**
  String get startRecording;

  /// No description provided for @startStream.
  ///
  /// In ru, this message translates to:
  /// **'Начать трансляцию'**
  String get startStream;

  /// No description provided for @droppedFrames.
  ///
  /// In ru, this message translates to:
  /// **'пропущено кадров: {n}'**
  String droppedFrames(int n);

  /// No description provided for @liveTooSlow.
  ///
  /// In ru, this message translates to:
  /// **'Кодирование не успевает (скорость {speed}×) — уменьшите разрешение, частоту кадров или включите аппаратное кодирование'**
  String liveTooSlow(String speed);

  /// No description provided for @liveBusy.
  ///
  /// In ru, this message translates to:
  /// **'Уже идёт другая запись или трансляция'**
  String get liveBusy;

  /// No description provided for @groupScreen.
  ///
  /// In ru, this message translates to:
  /// **'Экран'**
  String get groupScreen;

  /// No description provided for @groupCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get groupCamera;

  /// No description provided for @pCaptureRegion.
  ///
  /// In ru, this message translates to:
  /// **'Только часть экрана'**
  String get pCaptureRegion;

  /// No description provided for @pCaptureRegionHint.
  ///
  /// In ru, this message translates to:
  /// **'Левый верхний угол и размер в пикселях'**
  String get pCaptureRegionHint;

  /// No description provided for @wholeScreen.
  ///
  /// In ru, this message translates to:
  /// **'Весь экран'**
  String get wholeScreen;

  /// No description provided for @widthLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ширина'**
  String get widthLabel;

  /// No description provided for @heightLabel.
  ///
  /// In ru, this message translates to:
  /// **'Высота'**
  String get heightLabel;

  /// No description provided for @pDrawMouse.
  ///
  /// In ru, this message translates to:
  /// **'Показывать курсор'**
  String get pDrawMouse;

  /// No description provided for @pDrawMouseHint.
  ///
  /// In ru, this message translates to:
  /// **'Указатель мыши попадёт в запись'**
  String get pDrawMouseHint;

  /// No description provided for @pCaptureFpsHint.
  ///
  /// In ru, this message translates to:
  /// **'30 — для презентаций, 60 — для игр и быстрого движения'**
  String get pCaptureFpsHint;

  /// No description provided for @pCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get pCamera;

  /// No description provided for @pCameraHint.
  ///
  /// In ru, this message translates to:
  /// **'Устройство видеозахвата'**
  String get pCameraHint;

  /// No description provided for @noCameras.
  ///
  /// In ru, this message translates to:
  /// **'Камеры не найдены'**
  String get noCameras;

  /// No description provided for @groupCaptureAudio.
  ///
  /// In ru, this message translates to:
  /// **'Звук'**
  String get groupCaptureAudio;

  /// No description provided for @microphone.
  ///
  /// In ru, this message translates to:
  /// **'микрофон / вход'**
  String get microphone;

  /// No description provided for @systemAudio.
  ///
  /// In ru, this message translates to:
  /// **'звук компьютера'**
  String get systemAudio;

  /// No description provided for @noAudioDevices.
  ///
  /// In ru, this message translates to:
  /// **'Устройства звука не найдены'**
  String get noAudioDevices;

  /// No description provided for @systemAudioWindows.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы записать звук компьютера, включите устройство «Стерео микшер» (Stereo Mix) в настройках звука Windows или установите виртуальное аудиоустройство.'**
  String get systemAudioWindows;

  /// No description provided for @systemAudioLinux.
  ///
  /// In ru, this message translates to:
  /// **'Источники «.monitor» записывают то, что играет компьютер.'**
  String get systemAudioLinux;

  /// No description provided for @pCaptureQualityHint.
  ///
  /// In ru, this message translates to:
  /// **'Кодирование идёт в реальном времени; при пропуске кадров выберите качество пониже'**
  String get pCaptureQualityHint;

  /// No description provided for @pSaveMp4.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить в MP4'**
  String get pSaveMp4;

  /// No description provided for @pSaveMp4Hint.
  ///
  /// In ru, this message translates to:
  /// **'Запись идёт в MKV (не портится при сбое), после остановки — перепаковка в MP4 без потерь'**
  String get pSaveMp4Hint;

  /// No description provided for @waylandNote.
  ///
  /// In ru, this message translates to:
  /// **'Сеанс Wayland: x11grab записывает только окна XWayland, остальное может быть чёрным. Для полноценной записи войдите в сеанс X11.'**
  String get waylandNote;

  /// No description provided for @groupStreamTarget.
  ///
  /// In ru, this message translates to:
  /// **'Куда транслировать'**
  String get groupStreamTarget;

  /// No description provided for @pService.
  ///
  /// In ru, this message translates to:
  /// **'Сервис'**
  String get pService;

  /// No description provided for @pServiceHint.
  ///
  /// In ru, this message translates to:
  /// **'Адрес сервера подставится сам'**
  String get pServiceHint;

  /// No description provided for @customServer.
  ///
  /// In ru, this message translates to:
  /// **'Свой сервер (RTMP/SRT)'**
  String get customServer;

  /// No description provided for @serverUrl.
  ///
  /// In ru, this message translates to:
  /// **'Адрес сервера'**
  String get serverUrl;

  /// No description provided for @streamKey.
  ///
  /// In ru, this message translates to:
  /// **'Ключ трансляции'**
  String get streamKey;

  /// No description provided for @streamKeyHint.
  ///
  /// In ru, this message translates to:
  /// **'Из панели управления трансляцией; не показывайте его никому'**
  String get streamKeyHint;

  /// No description provided for @groupStreamSource.
  ///
  /// In ru, this message translates to:
  /// **'Что транслировать'**
  String get groupStreamSource;

  /// No description provided for @pStreamSource.
  ///
  /// In ru, this message translates to:
  /// **'Источник'**
  String get pStreamSource;

  /// No description provided for @pStreamSourceHint.
  ///
  /// In ru, this message translates to:
  /// **'Экран, камера или готовый файл'**
  String get pStreamSourceHint;

  /// No description provided for @sourceScreen.
  ///
  /// In ru, this message translates to:
  /// **'Экран'**
  String get sourceScreen;

  /// No description provided for @sourceCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get sourceCamera;

  /// No description provided for @sourceFile.
  ///
  /// In ru, this message translates to:
  /// **'Файл'**
  String get sourceFile;

  /// No description provided for @pLoopFile.
  ///
  /// In ru, this message translates to:
  /// **'По кругу'**
  String get pLoopFile;

  /// No description provided for @pLoopFileHint.
  ///
  /// In ru, this message translates to:
  /// **'Повторять файл, пока не остановите'**
  String get pLoopFileHint;

  /// No description provided for @groupStreamQuality.
  ///
  /// In ru, this message translates to:
  /// **'Качество трансляции'**
  String get groupStreamQuality;

  /// No description provided for @pStreamBitrate.
  ///
  /// In ru, this message translates to:
  /// **'Битрейт видео'**
  String get pStreamBitrate;

  /// No description provided for @pStreamBitrateHint.
  ///
  /// In ru, this message translates to:
  /// **'1080p30 — 4500–6000, 720p30 — 2500–4000; не больше 70% скорости отдачи интернета'**
  String get pStreamBitrateHint;

  /// No description provided for @groupPackage.
  ///
  /// In ru, this message translates to:
  /// **'Адаптивное видео'**
  String get groupPackage;

  /// No description provided for @pPackageFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат'**
  String get pPackageFormat;

  /// No description provided for @hlsHint.
  ///
  /// In ru, this message translates to:
  /// **'Apple HLS — играет везде: браузеры, iOS, Android, Smart TV'**
  String get hlsHint;

  /// No description provided for @dashHint.
  ///
  /// In ru, this message translates to:
  /// **'MPEG-DASH — открытый стандарт для веб-плееров (dash.js, Shaka)'**
  String get dashHint;

  /// No description provided for @pLadder.
  ///
  /// In ru, this message translates to:
  /// **'Качества'**
  String get pLadder;

  /// No description provided for @pLadderHint.
  ///
  /// In ru, this message translates to:
  /// **'Плеер переключается между ними по скорости интернета; выше исходника не создаются'**
  String get pLadderHint;

  /// No description provided for @pSegment.
  ///
  /// In ru, this message translates to:
  /// **'Длина сегмента'**
  String get pSegment;

  /// No description provided for @pSegmentHint.
  ///
  /// In ru, this message translates to:
  /// **'Короче — быстрее старт и переключение, больше файлов'**
  String get pSegmentHint;

  /// No description provided for @ladderSummary.
  ///
  /// In ru, this message translates to:
  /// **'Качества: {list}'**
  String ladderSummary(String list);

  /// No description provided for @packageFolderNote.
  ///
  /// In ru, this message translates to:
  /// **'Все файлы будут в папке {dir}; загрузите её на сервер целиком'**
  String packageFolderNote(String dir);

  /// No description provided for @appUpdateAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Доступна Kadra {version}'**
  String appUpdateAvailable(String version);

  /// No description provided for @updateDownloading.
  ///
  /// In ru, this message translates to:
  /// **'Скачивается Kadra {version}…'**
  String updateDownloading(String version);

  /// No description provided for @updateReady.
  ///
  /// In ru, this message translates to:
  /// **'Kadra {version} скачана и готова к установке'**
  String updateReady(String version);

  /// No description provided for @updateInstalling.
  ///
  /// In ru, this message translates to:
  /// **'Установка обновления…'**
  String get updateInstalling;

  /// No description provided for @updateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Обновление до {version}'**
  String updateTitle(String version);

  /// No description provided for @updateFromTo.
  ///
  /// In ru, this message translates to:
  /// **'Установлена {current}, новая {next}'**
  String updateFromTo(String current, String next);

  /// No description provided for @updateUpToDate.
  ///
  /// In ru, this message translates to:
  /// **'У вас последняя версия ({version})'**
  String updateUpToDate(String version);

  /// No description provided for @updateChecking.
  ///
  /// In ru, this message translates to:
  /// **'Проверка обновлений…'**
  String get updateChecking;

  /// No description provided for @updateNotChecked.
  ///
  /// In ru, this message translates to:
  /// **'Обновления ещё не проверялись'**
  String get updateNotChecked;

  /// No description provided for @updateFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обновить: {error}'**
  String updateFailed(String error);

  /// No description provided for @updateManual.
  ///
  /// In ru, this message translates to:
  /// **'Эта копия не может обновиться сама (нет прав на запись в её папку или нет подходящего файла). Скачайте новую версию со страницы релиза.'**
  String get updateManual;

  /// No description provided for @updateInterruptsJobs.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Идёт {count} задача, она будет отменена.} few{Идут {count} задачи, они будут отменены.} many{Идут {count} задач, они будут отменены.} other{Идут {count} задачи, они будут отменены.}} Приложение перезапустится.'**
  String updateInterruptsJobs(int count);

  /// No description provided for @whatsNew.
  ///
  /// In ru, this message translates to:
  /// **'Что нового'**
  String get whatsNew;

  /// No description provided for @restartAndUpdate.
  ///
  /// In ru, this message translates to:
  /// **'Перезапустить и обновить'**
  String get restartAndUpdate;

  /// No description provided for @skipVersion.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить версию'**
  String get skipVersion;

  /// No description provided for @openReleasePage.
  ///
  /// In ru, this message translates to:
  /// **'Страница релиза'**
  String get openReleasePage;

  /// No description provided for @checkNow.
  ///
  /// In ru, this message translates to:
  /// **'Проверить'**
  String get checkNow;

  /// No description provided for @appVersionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Kadra {version}'**
  String appVersionLabel(String version);

  /// No description provided for @channelBeta.
  ///
  /// In ru, this message translates to:
  /// **'Бета'**
  String get channelBeta;

  /// No description provided for @setAppUpdate.
  ///
  /// In ru, this message translates to:
  /// **'Проверять обновления Kadra'**
  String get setAppUpdate;

  /// No description provided for @setAppUpdateHint.
  ///
  /// In ru, this message translates to:
  /// **'При запуске и периодически, через GitHub Releases'**
  String get setAppUpdateHint;

  /// No description provided for @setAppUpdateHelp.
  ///
  /// In ru, this message translates to:
  /// **'Kadra спрашивает у GitHub, вышла ли новая версия. Обновление скачивается в фоне и проверяется по SHA-256; ставится только по кнопке «Перезапустить и обновить». Установщик обновляется установщиком, ZIP и tar.gz — заменой файлов в папке, AppImage — заменой файла.'**
  String get setAppUpdateHelp;

  /// No description provided for @setAppChannel.
  ///
  /// In ru, this message translates to:
  /// **'Канал обновлений'**
  String get setAppChannel;

  /// No description provided for @setAppChannelHint.
  ///
  /// In ru, this message translates to:
  /// **'Бета — раньше получать новые функции'**
  String get setAppChannelHint;

  /// No description provided for @setAppChannelHelp.
  ///
  /// In ru, this message translates to:
  /// **'Стабильный канал — только проверенные выпуски. Бета — ещё и предварительные (pre-release на GitHub): новые функции раньше, но возможны ошибки. Вернуться на стабильный можно в любой момент; бета-версия заменится следующим стабильным выпуском.'**
  String get setAppChannelHelp;

  /// No description provided for @setAppUpdateHours.
  ///
  /// In ru, this message translates to:
  /// **'Как часто проверять'**
  String get setAppUpdateHours;

  /// No description provided for @setAppUpdateHoursHint.
  ///
  /// In ru, this message translates to:
  /// **'Пока приложение открыто'**
  String get setAppUpdateHoursHint;

  /// No description provided for @everyHours.
  ///
  /// In ru, this message translates to:
  /// **'{hours, plural, one{раз в {hours} час} few{раз в {hours} часа} many{раз в {hours} часов} other{раз в {hours} часа}}'**
  String everyHours(int hours);

  /// No description provided for @setAppAutoDownload.
  ///
  /// In ru, this message translates to:
  /// **'Скачивать обновление в фоне'**
  String get setAppAutoDownload;

  /// No description provided for @setAppAutoDownloadHint.
  ///
  /// In ru, this message translates to:
  /// **'Установка всё равно только по кнопке'**
  String get setAppAutoDownloadHint;

  /// No description provided for @setCloseToTray.
  ///
  /// In ru, this message translates to:
  /// **'Работать в трее'**
  String get setCloseToTray;

  /// No description provided for @setCloseToTrayHint.
  ///
  /// In ru, this message translates to:
  /// **'Если идут задачи, закрытие окна сворачивает его в трей'**
  String get setCloseToTrayHint;

  /// No description provided for @setCloseToTrayHelp.
  ///
  /// In ru, this message translates to:
  /// **'Значок Kadra в области уведомлений показывает ход задач; через его меню можно открыть окно или выйти. Если задач нет, окно закрывается как обычно. Без трея при закрытии с задачами Kadra спросит, отменить ли их. В GNOME значок виден только с расширением AppIndicator (в Ubuntu оно включено).'**
  String get setCloseToTrayHelp;

  /// No description provided for @setPreventSleep.
  ///
  /// In ru, this message translates to:
  /// **'Не давать компьютеру уснуть'**
  String get setPreventSleep;

  /// No description provided for @setPreventSleepHint.
  ///
  /// In ru, this message translates to:
  /// **'Пока идут задачи, запись или трансляция'**
  String get setPreventSleepHint;

  /// No description provided for @hiddenToTray.
  ///
  /// In ru, this message translates to:
  /// **'Kadra продолжает работу в трее и сообщит, когда всё будет готово'**
  String get hiddenToTray;

  /// No description provided for @quitBusyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из Kadra?'**
  String get quitBusyTitle;

  /// No description provided for @quitBusyBody.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Идёт {count} задача — она будет отменена.} few{Идут {count} задачи — они будут отменены.} many{Идут {count} задач — они будут отменены.} other{Идут {count} задачи — они будут отменены.}}'**
  String quitBusyBody(int count);

  /// No description provided for @quitAnyway.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get quitAnyway;

  /// No description provided for @trayOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открыть Kadra'**
  String get trayOpen;

  /// No description provided for @trayQuit.
  ///
  /// In ru, this message translates to:
  /// **'Выход'**
  String get trayQuit;

  /// No description provided for @trayIdle.
  ///
  /// In ru, this message translates to:
  /// **'Задач нет'**
  String get trayIdle;

  /// No description provided for @trayBusy.
  ///
  /// In ru, this message translates to:
  /// **'Задач: {count} · {percent}%'**
  String trayBusy(int count, int percent);

  /// No description provided for @notifyOneDone.
  ///
  /// In ru, this message translates to:
  /// **'Готово: {title}'**
  String notifyOneDone(String title);

  /// No description provided for @notifyOneFailed.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: {title}'**
  String notifyOneFailed(String title);

  /// No description provided for @notifyManyDone.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Готова {count} задача} few{Готовы {count} задачи} many{Готово {count} задач} other{Готово {count} задачи}}'**
  String notifyManyDone(int count);

  /// No description provided for @notifyManyFailed.
  ///
  /// In ru, this message translates to:
  /// **'Завершено задач: {count}, с ошибкой: {failed}'**
  String notifyManyFailed(int count, int failed);

  /// No description provided for @fileTypeImages.
  ///
  /// In ru, this message translates to:
  /// **'Изображения'**
  String get fileTypeImages;

  /// No description provided for @fileTypeFonts.
  ///
  /// In ru, this message translates to:
  /// **'Шрифты'**
  String get fileTypeFonts;

  /// No description provided for @fileTypeLut.
  ///
  /// In ru, this message translates to:
  /// **'3D LUT'**
  String get fileTypeLut;

  /// No description provided for @fileTypeSubtitles.
  ///
  /// In ru, this message translates to:
  /// **'Субтитры'**
  String get fileTypeSubtitles;

  /// No description provided for @fileTypeText.
  ///
  /// In ru, this message translates to:
  /// **'Текстовые файлы'**
  String get fileTypeText;

  /// No description provided for @recipesImported.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Импортирован {count} рецепт} few{Импортировано {count} рецепта} many{Импортировано {count} рецептов} other{Импортировано {count} рецепта}}'**
  String recipesImported(int count);

  /// No description provided for @recipesExported.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Экспортирован {count} рецепт} few{Экспортировано {count} рецепта} many{Экспортировано {count} рецептов} other{Экспортировано {count} рецепта}}'**
  String recipesExported(int count);

  /// No description provided for @recipesImportFailed.
  ///
  /// In ru, this message translates to:
  /// **'Это не файл рецептов Kadra.'**
  String get recipesImportFailed;
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
