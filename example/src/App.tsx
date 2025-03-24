import { useEffect, useRef, useState } from 'react';
import { View, StyleSheet, Button } from 'react-native';
import {
  addNativeViewStateChangeListener,
  addSomeNativeSingletonListener,
  callSomeNativeFunction,
  SomeNativeView,
  type InappstoriesViewRef,
  type SingletonEvent,
  type StateChangeEvent,
} from 'react-native-inappstories';

export default function App() {
  const [, setLogs] = useState<string[]>([]);

  const viewRef1 = useRef<InappstoriesViewRef>(null);
  const viewRef2 = useRef<InappstoriesViewRef>(null);

  const addLog = (message: string) => {
    console.log(message); // Log to terminal as well
    setLogs((currentLogs) => [message, ...currentLogs]);
  };

  useEffect(() => {
    // Listen for singleton events
    const unsubscribeSingleton = addSomeNativeSingletonListener(
      (event: SingletonEvent) => {
        addLog(`Singleton event received: ${event.type}`);
      }
    );

    // Listen for all view state changes (for debugging)
    const unsubscribeViewState = addNativeViewStateChangeListener(
      (event: StateChangeEvent) => {
        addLog(
          `View #${event.viewTag} changed state to: ${event.state} ${
            event.data ? JSON.stringify(event.data) : ''
          }`
        );
      }
    );

    return () => {
      unsubscribeSingleton();
      unsubscribeViewState();
    };
  }, []);

  const handleStateChange = (state: string, data: any) => {
    console.log(`State changed to: ${state}`, data);
  };

  const triggerSingletonFunction = async () => {
    addLog('Calling SomeNativeSingleton.someNativeFunction()...');
    try {
      const result = await callSomeNativeFunction();
      addLog(
        `SomeNativeSingleton.someNativeFunction completed with: ${result}`
      );
    } catch (error) {
      addLog(`Error: ${error}`);
    }
  };

  const handleLoadFirst = () => {
    console.log('Loading...');
    viewRef1.current?.load('#ff0000'); // Load with red color
  };

  const handleLoadSecond = () => {
    console.log('Loading...');
    viewRef2.current?.load('#fff322'); // Load with yellow color
  };

  return (
    <View style={styles.container}>
      <>
        <SomeNativeView
          ref={viewRef1}
          style={styles.nativeView}
          onStateChange={handleStateChange}
        />
        <View style={styles.button}>
          <Button title="Load View" onPress={handleLoadFirst} />
        </View>
      </>
      <>
        <SomeNativeView
          ref={viewRef2}
          style={styles.nativeView}
          onStateChange={handleStateChange}
        />
        <View style={styles.button}>
          <Button title="Load View" onPress={handleLoadSecond} />
        </View>
      </>
      <View style={styles.button}>
        <Button title="Call Singleton" onPress={triggerSingletonFunction} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'white',
  },
  nativeView: {
    height: 150,
    width: 150,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#ddd',
    backgroundColor: '#f9f9f9',
    marginBottom: 20,
  },
  button: {
    marginBottom: 20,
  },
});
