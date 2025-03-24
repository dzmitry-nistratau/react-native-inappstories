import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export type NativeViewState = 'initial' | 'loading' | 'loaded';

export interface LoadedStateData {
  color: string; // Hex color code
}

export interface StateChangeEvent {
  viewTag: number;
  state: NativeViewState;
  data?: LoadedStateData;
}

export interface SingletonEvent {
  type: string;
}

export interface Spec extends TurboModule {
  callSomeNativeFunction(): Promise<boolean>;

  // Event emitter methods
  addListener(eventName: string): void;
  removeListeners(count: number): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('Inappstories');
