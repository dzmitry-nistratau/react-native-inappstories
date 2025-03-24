import {
  NativeModules,
  Platform,
  UIManager,
  findNodeHandle,
  NativeEventEmitter,
  type StyleProp,
  type ViewStyle,
} from 'react-native';
import type {
  Spec,
  StateChangeEvent,
  SingletonEvent,
  NativeViewState,
} from './NativeInappstories';
import { useRef, useImperativeHandle, useEffect, forwardRef } from 'react';
import InappstoriesViewNativeComponent from './InappstoriesViewNativeComponent';
import type { InappstoriesViewRef } from './InappstoriesViewNativeComponent';

const LINKING_ERROR =
  `The package 'react-native-inappstories' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

// @ts-expect-error
const isTurboModuleEnabled = global.__turboModuleProxy != null;

const InappstoriesModule = isTurboModuleEnabled
  ? require('./NativeInappstories').default
  : NativeModules.Inappstories;

const Inappstories: Spec = InappstoriesModule
  ? InappstoriesModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

// Export singleton function
export function callSomeNativeFunction(): Promise<boolean> {
  return Inappstories.callSomeNativeFunction();
}

// Event handling
const inappstoriesEventEmitter = new NativeEventEmitter(InappstoriesModule);

export function addSomeNativeSingletonListener(
  callback: (event: SingletonEvent) => void
): () => void {
  const subscription = inappstoriesEventEmitter.addListener(
    'someDelegateFunction',
    callback
  );

  return () => subscription.remove();
}

export function addNativeViewStateChangeListener(
  callback: (event: StateChangeEvent) => void
): () => void {
  const subscription = inappstoriesEventEmitter.addListener(
    'nativeViewStateChange',
    callback
  );

  return () => subscription.remove();
}

export interface SomeNativeViewProps {
  style?: StyleProp<ViewStyle>;
  onStateChange?: (state: string, data: any) => void;
}

const getCommandId = (commandName: string): number => {
  // Use type assertion to avoid TypeScript errors
  const viewConfig = UIManager.getViewManagerConfig('InappstoriesView');
  const commandID = viewConfig?.Commands?.[commandName];

  if (typeof commandID === 'number') {
    return commandID;
  }

  // If we can't find the command ID, log a warning and return 0 (a safe fallback)
  console.warn(`Command ID for ${commandName} not found`);
  return 0;
};

export const SomeNativeView = forwardRef<
  InappstoriesViewRef,
  SomeNativeViewProps
>((props, ref) => {
  const nativeRef = useRef(null);

  useImperativeHandle(ref, () => ({
    load: (loadColor?: string) => {
      const tag = findNodeHandle(nativeRef.current);
      if (tag) {
        if (Platform.OS === 'android') {
          // For Android, we need different handling
          UIManager.dispatchViewManagerCommand(
            tag,
            // On Android, Commands might be string-keyed
            (UIManager as any).InappstoriesView.Commands.load,
            [loadColor || '']
          );
        } else {
          // For iOS, use numeric command ID
          UIManager.dispatchViewManagerCommand(tag, getCommandId('load'), [
            loadColor || '',
          ]);
        }
      }
    },
  }));

  useEffect(() => {
    let listener: (() => void) | null = null;

    if (props.onStateChange) {
      listener = addNativeViewStateChangeListener((event) => {
        try {
          const tag = findNodeHandle(nativeRef.current);
          console.log('Native event received:', JSON.stringify(event));

          if (event && event.viewTag && event.viewTag === tag) {
            // Ensure we have valid data to pass to the callback
            const safeState = event.state || 'unknown';
            const safeData = event.data || {};
            props.onStateChange?.(safeState, safeData);
          }
        } catch (error) {
          console.error('Error handling state change event:', error);
        }
      });
    }

    return () => {
      if (listener) {
        listener();
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [props.onStateChange]);

  const handleStateChange = (event: any) => {
    if (props.onStateChange) {
      props.onStateChange(event.nativeEvent.state, event.nativeEvent.data);
    }
  };

  return (
    <InappstoriesViewNativeComponent
      ref={nativeRef}
      {...props}
      onStateChange={handleStateChange}
    />
  );
});

export type {
  NativeViewState,
  StateChangeEvent,
  SingletonEvent,
  InappstoriesViewRef,
};
