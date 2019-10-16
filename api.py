import joblib
import os
from typing import Dict
from fastapi import FastAPI
from pydantic import BaseModel
from utils import get_logger

LOG_LEVEL = os.getenv('LOG_LEVEL', 'debug')
MODEL_PATH = os.getenv('MODEL_PATH', 'models/svm.joblib')


app = FastAPI(docs_url="/docs", redoc_url=None)
logger = get_logger('sklearn-api', LOG_LEVEL)

# define ML models as global variables to only load them when the app starts
logger.info(f'Loading model from "{MODEL_PATH}"')
iris_clf = joblib.load(MODEL_PATH)


class IrisData(BaseModel):
    sepal_length: float
    sepal_width: float
    petal_length: float
    petal_width: float


class ClassifierResult(BaseModel):
    probabilities: Dict[str, float]


@app.post("/classify", response_model=ClassifierResult)
def classify(item: IrisData):
    data = [[item.sepal_length, item.sepal_width, item.petal_length, item.petal_width]]
    logger.debug(f'got iris data: {data}')

    probs = iris_clf.predict_proba(data)
    logger.debug(f'iris_clf.predict_proba results: {probs}')

    class_probs = dict(zip(iris_clf.classes_, probs[0]))

    return ClassifierResult(probabilities=class_probs)