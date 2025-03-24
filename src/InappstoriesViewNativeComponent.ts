import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { ViewProps } from 'react-native';
import type { DirectEventHandler } from 'react-native/Libraries/Types/CodegenTypes';

interface StateChangeEventData {
  state: string; // Use string instead of NativeViewState for codegen
  data?: {
    color?: string;
  };
}

interface NativeProps extends ViewProps {
  color?: string;
  // Use the explicit event structure
  onStateChange?: DirectEventHandler<StateChangeEventData>;
}

export default codegenNativeComponent<NativeProps>('InappstoriesView');

export interface InappstoriesViewRef {
  load: (color?: string) => void;
}
