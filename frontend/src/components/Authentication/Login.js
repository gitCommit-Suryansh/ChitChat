import React, { useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const submitHandler = async () => {
    setLoading(true);
    if (!email || !password) {
      alert("Please Fill all the Feilds");
      setLoading(false);
      return;
    }

    try {
      const config = {
        headers: {
          "Content-type": "application/json",
        },
      };

      const { data } = await axios.post(
        "/api/user/login",
        { email, password },
        config,
      );

      alert("Login Successful");
      localStorage.setItem("userInfo", JSON.stringify(data));
      setLoading(false);
      navigate("/chats");
    } catch (error) {
      alert("Error Occured: " + error.response.data.message);
      setLoading(false);
    }
  };

  return (
    <div className="v-stack space-y-4">
      <div className="form-control">
        <label className="label">
          <span className="label-text">Email Address</span>
        </label>
        <input
          type="email"
          placeholder="Enter Your Email Address"
          className="input input-bordered w-full p-2 border rounded"
          onChange={(e) => setEmail(e.target.value)}
          value={email}
        />
      </div>
      <div className="form-control">
        <label className="label">
          <span className="label-text">Password</span>
        </label>
        <div className="input-group">
          <input
            type="password"
            placeholder="Enter Password"
            className="input input-bordered w-full p-2 border rounded"
            onChange={(e) => setPassword(e.target.value)}
            value={password}
          />
        </div>
      </div>
      <button
        className={`btn btn-primary w-full p-2 bg-blue-500 text-white rounded hover:bg-blue-600 ${loading ? "opacity-50 cursor-not-allowed" : ""}`}
        onClick={submitHandler}
        disabled={loading}
      >
        {loading ? "Loading..." : "Login"}
      </button>
      <button
        className="btn btn-secondary w-full p-2 bg-red-500 text-white rounded hover:bg-red-600 mt-2"
        onClick={() => {
          setEmail("guest@example.com");
          setPassword("123456");
        }}
      >
        Get Guest User Credentials
      </button>
    </div>
  );
};

export default Login;
