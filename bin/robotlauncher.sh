#!/bin/sh

if [[ ${SITE_PIPELINE_OPTION} == ${BASESITE} || ${SITE_PIPELINE_OPTION} == 'all' ]]; then
    echo "Site is selected for execution";
else
    echo "Site is NOT selected for execution";
    exit 0
fi
echo
echo "#######################################"
echo "# Running tests first iteration     #"
echo "#######################################"
echo


echo "#######################################"
echo "# Running Functional tests      #"
echo "#######################################"
echo 
pabot --processes 4 --ordering pabot_order.txt .

# we stop the script here if all the tests were OK
if [ $? -eq 0 ]; then
    echo "we don't run the tests again as everything was OK on first try"
    exit 0
elif ${DISABLE_RETRIES}; then
    exit 1
fi
# otherwise we go for another round with the failing tests

# we keep a copy of the first log file
echo "Copy log.html to first_run_log.html"
cp TestResults/${BASESITE}_${ENV}/log.html  TestResults/${BASESITE}_${ENV}/first_run_log.html
if ${TEST_DEBUG}; then
    cp -r TestResults/${BASESITE}_${ENV}/pabot_results  TestResults/${BASESITE}_${ENV}/first_pabot_results
fi
# we launch the tests that failed
echo "#######################################"
echo "# Running again Functional tests that failed     #"
echo "#######################################"
echo
pabot --processes 4 --ordering pabot_order.txt --nostatusrc --rerunfailed TestResults/${BASESITE}_${ENV}/output.xml --output secondrun.xml .

# we keep a copy of the second log file
echo "Copy log.html to second_run_log.html"
cp TestResults/${BASESITE}_${ENV}/log.html  TestResults/${BASESITE}_${ENV}/second_run_log.html
if ${TEST_DEBUG}; then
    cp -r TestResults/${BASESITE}_${ENV}/pabot_results  TestResults/${BASESITE}_${ENV}/second_pabot_results
fi
rebot --outputdir TestResults/${BASESITE}_${ENV} -x xunitoutput.xml --output output.xml --merge TestResults/${BASESITE}_${ENV}/output.xml  TestResults/${BASESITE}_${ENV}/secondrun.xml

pabot --processes 4 --ordering pabot_order.txt --nostatusrc --rerunfailed TestResults/${BASESITE}_${ENV}/secondrun.xml --output thirdrun.xml .
echo "Copy log.html to third_run_log.html"
cp TestResults/${BASESITE}_${ENV}/log.html  TestResults/${BASESITE}_${ENV}/third_run_log.html
if ${TEST_DEBUG}; then
    cp -r TestResults/${BASESITE}_${ENV}/pabot_results  TestResults/${BASESITE}_${ENV}/third_pabot_results
fi
if [ -f "TestResults/${BASESITE}_${ENV}/thirdrun.xml" ]; then
    rebot  --outputdir TestResults/${BASESITE}_${ENV} -x xunitoutput.xml --output output.xml --merge TestResults/${BASESITE}_${ENV}/output.xml  TestResults/${BASESITE}_${ENV}/thirdrun.xml
fi

# Robot Framework generates a new Output.xml