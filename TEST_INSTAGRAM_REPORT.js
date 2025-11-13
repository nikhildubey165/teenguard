// Test script to check Instagram data in reports
// Run this in browser console while logged in

async function testInstagramReport() {
  console.log('🔍 Testing Instagram report data...');
  
  try {
    // Get auth token
    const token = localStorage.getItem('token');
    if (!token) {
      console.error('❌ No auth token found');
      return;
    }
    
    console.log('✅ Auth token found');
    
    // Test 1: Check all usage records
    console.log('\n📊 Test 1: Checking all usage records...');
    const usageResponse = await fetch('/api/usage/app?days=30', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    const usageData = await usageResponse.json();
    
    console.log('All usage records:', usageData.usage);
    
    const instagramUsage = usageData.usage.filter(u => 
      u.app_name.toLowerCase().includes('instagram')
    );
    console.log('Instagram usage records:', instagramUsage);
    
    // Test 2: Check report data
    console.log('\n📈 Test 2: Checking report data...');
    const reportResponse = await fetch('/api/usage/my-report?days=7', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    const reportData = await reportResponse.json();
    
    console.log('Report summary:', reportData.summary);
    
    const instagramReport = reportData.summary.find(s => 
      s.app_name.toLowerCase().includes('instagram')
    );
    console.log('Instagram in report:', instagramReport);
    
    // Test 3: Check today's usage specifically
    console.log('\n📅 Test 3: Checking today\'s usage...');
    console.log('Today\'s usage:', reportData.todayUsage);
    
    const instagramToday = reportData.todayUsage.find(t => 
      t.app_name.toLowerCase().includes('instagram')
    );
    console.log('Instagram today:', instagramToday);
    
    // Summary
    console.log('\n📋 SUMMARY:');
    console.log(`Total Instagram usage records: ${instagramUsage.length}`);
    console.log(`Instagram in report: ${instagramReport ? 'YES' : 'NO'}`);
    console.log(`Instagram today: ${instagramToday ? 'YES' : 'NO'}`);
    
    if (instagramUsage.length === 0) {
      console.log('❌ NO INSTAGRAM USAGE FOUND IN DATABASE');
      console.log('💡 This means Instagram usage is not being saved properly');
    } else {
      console.log('✅ Instagram usage found in database');
      if (!instagramReport) {
        console.log('❌ But not showing in report - possible query issue');
      }
    }
    
  } catch (error) {
    console.error('❌ Test failed:', error);
  }
}

// Run the test
testInstagramReport();
