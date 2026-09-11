/// Shared local Supabase endpoint for Windows desktop and the phone on the PC hotspot.
///
/// Do not use 127.0.0.1 here: on the phone that is the phone itself.
/// Windows 移动热点 gateway is usually 192.168.137.1 — override with --dart-define if needed.
const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'http://192.168.137.1:54321',
);

const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
