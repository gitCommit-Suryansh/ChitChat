import React, { useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";

const Signup = () => {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [confirmpassword, setConfirmpassword] = useState("");
  const [password, setPassword] = useState("");
  const [pic] = useState();
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const submitHandler = async () => {
    setLoading(true);
    if (!name || !email || !password || !confirmpassword) {
      alert("Please Fill all the Feilds");
      setLoading(false);
      return;
    }
    if (password !== confirmpassword) {
      alert("Passwords Do Not Match");
      return;
    }

    try {
      const config = {
        headers: {
          "Content-type": "application/json",
        },
      };
      const { data } = await axios.post(
        "/api/user",
        {
          name,
          email,
          password,
          pic,
        },
        config,
      );
      alert("Registration Successful");
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
          <span className="label-text">Name</span>
        </label>
        <input
          type="text"
          placeholder="Enter Your Name"
          className="input input-bordered w-full p-2 border rounded"
          onChange={(e) => setName(e.target.value)}
        />
      </div>
      <div className="form-control">
        <label className="label">
          <span className="label-text">Email Address</span>
        </label>
        <input
          type="email"
          placeholder="Enter Your Email Address"
          className="input input-bordered w-full p-2 border rounded"
          onChange={(e) => setEmail(e.target.value)}
        />
      </div>
      <div className="form-control">
        <label className="label">
          <span className="label-text">Password</span>
        </label>
        <input
          type="password"
          placeholder="Enter Password"
          className="input input-bordered w-full p-2 border rounded"
          onChange={(e) => setPassword(e.target.value)}
        />
      </div>
      <div className="form-control">
        <label className="label">
          <span className="label-text">Confirm Password</span>
        </label>
        <input
          type="password"
          placeholder="Confirm Password"
          className="input input-bordered w-full p-2 border rounded"
          onChange={(e) => setConfirmpassword(e.target.value)}
        />
      </div>
      {/* Picture upload logic omitted for brevity, can add later if needed */}
      <button
        className={`btn btn-primary w-full p-2 bg-blue-500 text-white rounded hover:bg-blue-600 ${loading ? "opacity-50 cursor-not-allowed" : ""}`}
        onClick={submitHandler}
        disabled={loading}
      >
        {loading ? "Loading..." : "Sign Up"}
      </button>
    </div>
  );
};

export default Signup;
