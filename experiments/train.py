import pandas as pd
from sklearn import svm
from joblib import dump


data = pd.read_csv('../data/iris.csv')
X, y = data.drop('species', 1), data.species

clf = svm.SVC(gamma='scale', probability=True)
clf.fit(X, y)

dump(clf, '../models/svm.joblib')