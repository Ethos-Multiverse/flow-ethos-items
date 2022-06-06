import "./flow/config";
import * as fcl from "@onflow/fcl";
import { useState, useEffect } from "react";

function App() {
  // UI State
  const [user, setUser] = useState(null);

  // Update user on page load
  useEffect(() => fcl.currentUser.subscribe(setUser), []);

  // Logged in user
  const AuthedState = () => {

    return (
      <h1>Logged In</h1>
    )
  }

  // Logout user
  const UnauthenticatedState = () => {
    return (
      <div>
        <button
          className="bg-gray-100 hover:bg-gray-200 focus:bg-gray-200 border hover:border-gray-300 focus:border-gray-300 rounded shadow-lg absolute top-4 right-4 lg:top-8 lg:right-8 p-4 flex items-center text-xs disabled:cursor-not-allowed"
          onClick={() => fcl.authenticate()}
        >
          {
            <>
              <span className="rounded-full h-2 w-2 block mr-2 bg-red-500" />
            </>
          }
          {/* {message} */}
          Connect Wallet
        </button>
        <div className="space-y-8">
          <h1 className="text-4xl font-semibold mb-8">
            EthosItems Marketplace
          </h1>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-xl mt-36 mx-auto px-4">
      {user?.loggedIn ? <AuthedState /> : <UnauthenticatedState />}
    </div>
  );
}

export default App;
