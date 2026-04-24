# Battery Virtual Sensor (Neural Network)

Build a neural network model to predict battery temperature from voltage and current measurements, enabling virtual sensor deployment to reduce physical sensor count.

| Item | Detail |
|------|--------|
| **Entry point** | `VirtualSensorNeuralNetModel.mlx` |
| **Template** | Electro-thermal (needs thermal battery data) |
| **Key outputs** | Trained neural network model, temperature prediction vs measured comparison |

## Files

| File | Purpose |
|------|---------|
| `VirtualSensorNeuralNetModel.mlx` | Main live script — open this to run the workflow |
| `VirtualSensorNNSimRes.m` | Simulation result processing |
| `VirtualSensorNNVerify.m` | Model verification utility |
| `VirtualSensorNNModelPreTrained.mat` | Pre-trained neural network model |
| `VirtualSensorNNDriveProfile01.mat` | Drive profile input data |
| `OpenVirtualSensorNNLiveScript.m` | Helper to open the live script |

Copyright 2022 - 2026 The MathWorks, Inc.
