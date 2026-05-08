import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export type Theme = 'light' | 'dark' | 'system' | 'senordev';

const VALID_THEMES = ['light', 'dark', 'system', 'senordev'] as const;

function normalizeTheme(value: unknown): Theme {
  return (VALID_THEMES as readonly string[]).includes(value as string)
    ? (value as Theme)
    : 'system';
}

function resolveTheme(theme: Theme): 'light' | 'dark' | 'senordev' {
  if (theme === 'system') {
    if (typeof window === 'undefined') return 'dark';
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }
  return theme;
}

export function applyTheme(theme: Theme) {
  if (typeof document === 'undefined') return;
  const resolved = resolveTheme(theme);
  const root = document.documentElement;
  root.classList.toggle('dark', resolved === 'dark');
  if (resolved === 'light') {
    root.removeAttribute('data-theme');
  } else {
    root.dataset.theme = resolved;
  }
}

// Draft state for the create voice profile form
export interface ProfileFormDraft {
  name: string;
  description: string;
  language: string;
  personality: string;
  referenceText: string;
  sampleMode: 'upload' | 'record' | 'system';
  // Note: File objects can't be persisted, so we store metadata
  sampleFileName?: string;
  sampleFileType?: string;
  sampleFileData?: string; // Base64 encoded
}

interface UIStore {
  // Sidebar
  sidebarOpen: boolean;
  setSidebarOpen: (open: boolean) => void;

  // Modals
  profileDialogOpen: boolean;
  setProfileDialogOpen: (open: boolean) => void;
  editingProfileId: string | null;
  setEditingProfileId: (id: string | null) => void;

  generationDialogOpen: boolean;
  setGenerationDialogOpen: (open: boolean) => void;

  // Selected profile for generation
  selectedProfileId: string | null;
  setSelectedProfileId: (id: string | null) => void;

  // Currently selected engine (synced from generation form)
  selectedEngine: string;
  setSelectedEngine: (engine: string) => void;

  // Selected voice in Voices tab inspector
  selectedVoiceId: string | null;
  setSelectedVoiceId: (id: string | null) => void;

  // Profile form draft (for persisting create voice modal state)
  profileFormDraft: ProfileFormDraft | null;
  setProfileFormDraft: (draft: ProfileFormDraft | null) => void;

  // Theme
  theme: Theme;
  setTheme: (theme: Theme) => void;
}

export const useUIStore = create<UIStore>()(
  persist(
    (set) => ({
      sidebarOpen: true,
      setSidebarOpen: (open) => set({ sidebarOpen: open }),

      profileDialogOpen: false,
      setProfileDialogOpen: (open) => set({ profileDialogOpen: open }),
      editingProfileId: null,
      setEditingProfileId: (id) => set({ editingProfileId: id }),

      generationDialogOpen: false,
      setGenerationDialogOpen: (open) => set({ generationDialogOpen: open }),

      selectedProfileId: null,
      setSelectedProfileId: (id) => set({ selectedProfileId: id }),

      selectedEngine: 'qwen',
      setSelectedEngine: (engine) => set({ selectedEngine: engine }),

      selectedVoiceId: null,
      setSelectedVoiceId: (id) => set({ selectedVoiceId: id }),

      profileFormDraft: null,
      setProfileFormDraft: (draft) => set({ profileFormDraft: draft }),

      theme: 'system',
      setTheme: (theme) => {
        set({ theme });
        applyTheme(theme);
      },
    }),
    {
      name: 'voicebox-ui',
      partialize: (state) => ({
        selectedProfileId: state.selectedProfileId,
        theme: state.theme,
      }),
      onRehydrateStorage: () => (state) => {
        if (!state) return;
        const normalized = normalizeTheme(state.theme);
        if (normalized !== state.theme) state.theme = normalized;
        applyTheme(normalized);
      },
    },
  ),
);
