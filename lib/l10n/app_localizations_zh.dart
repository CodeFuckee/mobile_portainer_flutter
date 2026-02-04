// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Docker 监控';

  @override
  String get titleContainers => '容器';

  @override
  String get titleImages => '镜像';

  @override
  String get titleSettings => '设置';

  @override
  String get labelDockerApiUrl => 'Docker API 地址';

  @override
  String get hintIpPort => 'http://ip:port';

  @override
  String get helperDockerApiUrl => '例如：Android 模拟器使用 http://10.0.2.2:2375';

  @override
  String get buttonSave => '保存';

  @override
  String get msgSettingsSaved => '设置已保存';

  @override
  String get msgNoContainers => '暂无容器';

  @override
  String get msgRetry => '重试';

  @override
  String msgCurrentApi(Object api) {
    return '当前 API：$api';
  }

  @override
  String get buttonRefresh => '刷新';

  @override
  String get labelLanguage => '语言';

  @override
  String get optionSystem => '系统默认';

  @override
  String get optionEnglish => 'English';

  @override
  String get optionChinese => '中文';

  @override
  String get labelApiKey => 'API 密钥';

  @override
  String get hintApiKey => '输入 API 密钥（可选）';

  @override
  String get helperApiKey => '某些 Portainer/Docker 配置需要此项';

  @override
  String get labelStack => '应用栈';

  @override
  String get labelImage => '镜像';

  @override
  String get labelPorts => '端口';

  @override
  String get labelSearch => '搜索';

  @override
  String get hintSearch => '搜索容器...';

  @override
  String get labelStatusAll => '全部';

  @override
  String get labelStatus => '状态';

  @override
  String get labelFilterStatus => '按状态过滤';

  @override
  String get labelFilterStack => '按堆栈过滤';

  @override
  String get actionStart => '启动';

  @override
  String get actionStop => '停止';

  @override
  String get actionKill => '强制停止';

  @override
  String get actionRestart => '重启';

  @override
  String get actionPause => '暂停';

  @override
  String get actionResume => '恢复';

  @override
  String get actionRemove => '删除';

  @override
  String get actionCancel => '取消';

  @override
  String get labelTimezone => '时区';

  @override
  String get optionUtc => 'UTC';

  @override
  String get optionUtcPlus8 => 'UTC+8 (中国)';

  @override
  String get optionUtcPlus9 => 'UTC+9 (日本)';

  @override
  String get optionUtcMinus5 => 'UTC-5 (美东)';

  @override
  String get optionUtcPlus1 => 'UTC+1 (中欧)';

  @override
  String get msgOperationNotAllowed => '不允许对该容器进行操作';

  @override
  String get sectionServers => '服务器列表';

  @override
  String get buttonAddServer => '添加服务器';

  @override
  String get labelServerName => '服务器名称';

  @override
  String get msgServerAdded => '已添加服务器';

  @override
  String get msgServerUpdated => '已更新服务器';

  @override
  String get msgServerDeleted => '已删除服务器';

  @override
  String msgServerSwitched(Object name) {
    return '已切换到 $name';
  }

  @override
  String get actionEdit => '编辑';

  @override
  String get actionDelete => '删除';

  @override
  String get labelActive => '当前使用';

  @override
  String get titleDashboard => '概览';

  @override
  String get labelServerInfo => '服务器信息';

  @override
  String get labelTotal => '总计';

  @override
  String get labelRunning => '运行中';

  @override
  String get labelStopped => '已停止';

  @override
  String get msgWsConnected => 'WebSocket 已连接';

  @override
  String get msgWsDisconnected => 'WebSocket 已断开';

  @override
  String get titlePullImage => '拉取镜像';

  @override
  String get labelImageName => '镜像名称';

  @override
  String get hintImageName => '例如 docker.1ms.run/emqx/emqx';

  @override
  String get labelTag => 'Tag';

  @override
  String get hintTag => '例如 latest';

  @override
  String get buttonPull => '拉取';

  @override
  String get msgImageNameRequired => '镜像名称不能为空';

  @override
  String get msgImagePullSuccess => '镜像拉取成功';

  @override
  String msgImagePullFailed(Object error) {
    return '拉取失败: $error';
  }

  @override
  String get tabDetails => '详情';

  @override
  String get tabLogs => '日志';

  @override
  String get msgNoLogs => '暂无日志';

  @override
  String get msgLoadingLogs => '加载日志中...';

  @override
  String get tabOverview => '概览';

  @override
  String get tabNetwork => '网络';

  @override
  String get tabStorage => '存储';

  @override
  String get tabEnv => '环境';

  @override
  String get tabFiles => '文件';

  @override
  String get titleNetworks => '网络';

  @override
  String get hintSearchNetworks => '搜索网络...';

  @override
  String get labelDriver => '驱动';

  @override
  String get labelScope => '范围';

  @override
  String get titleStacks => '应用栈';

  @override
  String get hintSearchStacks => '搜索应用栈...';

  @override
  String get titleVolumes => '存储卷';

  @override
  String get hintSearchVolumes => '搜索存储卷...';

  @override
  String get titleResources => '资源';

  @override
  String get labelMountpoint => '挂载点';

  @override
  String get labelCreated => '创建时间';

  @override
  String get labelOptions => '选项';

  @override
  String get labelLabels => '标签';

  @override
  String get labelIgnoreSsl => '忽略 SSL 验证';

  @override
  String get msgErrorLoadingFiles => '加载文件失败';

  @override
  String msgFileSelected(Object name, Object size) {
    return '已选择文件: $name ($size)';
  }

  @override
  String get labelMounted => '已挂载';

  @override
  String get msgFileSaved => '文件保存成功';

  @override
  String msgErrorSavingFile(Object error) {
    return '保存文件失败: $error';
  }

  @override
  String get labelInUse => '已使用';

  @override
  String get titleConfirmDelete => '确认删除';

  @override
  String get msgConfirmDeleteImage => '确定要删除此镜像吗？';

  @override
  String get titleNewVersion => '发现新版本';

  @override
  String get msgNoUpdate => '当前已是最新版本';

  @override
  String get errCheckUpdate => '检查更新失败';

  @override
  String get actionUpdate => '立即更新';

  @override
  String get labelGithub => 'GitHub 仓库';

  @override
  String get buttonScanQr => '扫描二维码';

  @override
  String get msgScanSuccess => '扫码成功';

  @override
  String get msgInvalidQr => '二维码格式无效';

  @override
  String get buttonManualInput => '手动输入';

  @override
  String get titleRunContainer => '运行容器';

  @override
  String get labelCommand => '命令';

  @override
  String get hintCommand => '例如：docker run -d -p 80:80 nginx';

  @override
  String msgContainerStarted(Object id) {
    return '容器启动成功：$id';
  }

  @override
  String msgRunContainerFailed(Object error) {
    return '运行容器失败：$error';
  }

  @override
  String get actionRun => '运行';
}
