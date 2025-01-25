# Lab: Vulnerable Infra AWSGoat


- Change the directory.

```
mkdir -p /home/ec2-user/workspace/aws-security/cloud-labs/automatedscan
cd /home/ec2-user/workspace/aws-security/cloud-labs/automatedscan
```


- Create a user, attach the administrator policy, generate access keys, and print the export commands.

```
aws iam create-user --user-name AdminUser && aws iam attach-user-policy --user-name AdminUser --policy-arn arn:aws:iam::aws:policy/AdministratorAccess && aws iam create-access-key --user-name AdminUser --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text | awk '{print "export AWS_ACCESS_KEY_ID=\"" $1 "\"\nexport AWS_SECRET_ACCESS_KEY=\"" $2 "\""}'
```


- Clone the [AWSGoat](https://github.com/ine-labs/AWSGoat) for deploying vulnerable infra.

```
git clone https://github.com/ine-labs/AWSGoat
cd AWSGoat/modules/module-1
```

- Deploy vulnerable infrastructure.

```
rm /home/ec2-user/workspace/aws-security/cloud-labs/automatedscan/AWSGoat/modules/module-1/resources/dynamodb/populate-table.py
touch /home/ec2-user/workspace/aws-security/cloud-labs/automatedscan/AWSGoat/modules/module-1/resources/dynamodb/populate-table.py
tofu init
tofu apply --auto-approve
```

- Again change the directory.

```
cd /home/ec2-user/workspace/aws-security/cloud-labs/automatedscan
```

- Install the express, minimalist  web framework for Node.js. 

```
npm install express
```

- Create a simple `app.js` for reviewing the report.

```
cat << EOF > app.js
const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const port = process.env.PORT || 1337;

// Serve the directory listing at the root
app.get('/', (req, res) => {
  const directoryPath = path.join(__dirname, 'scoutsuite-report');
  fs.readdir(directoryPath, { withFileTypes: true }, (err, files) => {
    if (err) {
      console.error('Error reading directory:', err);
      return res.status(500).send('Error reading directory.');
    }

    const fileList = files
      .filter(file => file.isDirectory() || file.name.endsWith('.html')) // Filter directories and .html files
      .map(file => {
        const href = file.isDirectory() ? \`\${file.name}/\` : file.name;
        return \`<li><a href="\${href}">\${file.name}</a></li>\`;
      })
      .join('');

    res.send(\`
      <html>
        <head>
          <title>ScoutSuite Report</title>
        </head>
        <body>
          <h1>ScoutSuite Report Directory</h1>
          <ul>
            \${fileList}
          </ul>
        </body>
      </html>
    \`);
  });
});

// Serve static files only from the scoutsuite-report directory
app.use('/', express.static(path.join(__dirname, 'scoutsuite-report')));

app.listen(port, () => {
  console.log(\`Server started at http://localhost:\${port}\`);
});
EOF
```

## Cleanup (Optional)

<span style="color:red;">Disclaimer: If you are proceeding to the next lab, do NOT perform the cleanup steps, as this will delete all resources.</span>
 
```
cd /home/ec2-user/workspace/aws-security/cloud-labs/automatedscan/AWSGoat/modules/module-1
tofu destroy --auto-approve
```

## Credit

- [package/express](https://www.npmjs.com/package/express)
