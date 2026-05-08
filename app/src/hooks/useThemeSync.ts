import { useEffect } from 'react';
import { applyTheme, useUIStore } from '@/stores/uiStore';

export function useThemeSync() {
  const theme = useUIStore((s) => s.theme);

  useEffect(() => {
    applyTheme(theme);
    if (theme !== 'system') return;

    const mq = window.matchMedia('(prefers-color-scheme: dark)');
    const apply = () => applyTheme('system');
    mq.addEventListener('change', apply);
    return () => mq.removeEventListener('change', apply);
  }, [theme]);
}
